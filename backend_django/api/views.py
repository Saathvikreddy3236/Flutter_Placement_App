from django.contrib.auth import authenticate
from django.db.models import Avg, Count, Max, Q
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Application, Bookmark, Job, StudentProfile
from .serializers import (
    AdminApplicationSerializer,
    ApplicationSerializer,
    BookmarkSerializer,
    JobCreateSerializer,
    JobSerializer,
    StudentProfileSerializer,
)


def _resolve_student_profile(request):
    if request.user and request.user.is_authenticated:
        try:
            return StudentProfile.objects.select_related("user").get(user=request.user), None
        except StudentProfile.DoesNotExist:
            return None, Response({"error": "Student profile not found"}, status=400)

    student_id = request.data.get("student_id") or request.query_params.get("student_id")
    if not student_id:
        return None, Response(
            {"error": "student_id is required when user is not authenticated"},
            status=400,
        )

    try:
        return StudentProfile.objects.select_related("user").get(id=student_id), None
    except StudentProfile.DoesNotExist:
        return None, Response({"error": "Student profile not found"}, status=404)


def _resolve_student_profile_optional(request):
    if request.user and request.user.is_authenticated:
        try:
            return StudentProfile.objects.select_related("user").get(user=request.user)
        except StudentProfile.DoesNotExist:
            return None

    student_id = request.query_params.get("student_id")
    if not student_id:
        return None

    try:
        return StudentProfile.objects.select_related("user").get(id=student_id)
    except StudentProfile.DoesNotExist:
        return None


def _has_accepted_offer(student_profile):
    return Application.objects.filter(student=student_profile, status='Accepted').exists()


@api_view(['GET', 'PATCH'])
def user_profile(request):
    role = (request.data.get('role') or request.query_params.get('role') or '').strip()

    if role == 'admin':
        username = (
            request.data.get('username')
            or request.query_params.get('username')
            or ''
        ).strip()
        if not username:
            return Response({'error': 'username is required'}, status=400)

        from django.contrib.auth.models import User

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return Response({'error': 'Admin user not found'}, status=404)

        if request.method == 'GET':
            return Response(
                {
                    'role': 'admin',
                    'name': user.get_full_name() or user.username,
                    'username': user.username,
                    'email': user.email,
                }
            )

        new_name = (request.data.get('name') or user.get_full_name() or user.username).strip()
        new_email = (request.data.get('email') or '').strip()

        name_parts = new_name.split(maxsplit=1)
        user.first_name = name_parts[0] if name_parts else ''
        user.last_name = name_parts[1] if len(name_parts) > 1 else ''
        user.email = new_email
        user.save()

        return Response(
            {
                'role': 'admin',
                'name': user.get_full_name() or user.username,
                'username': user.username,
                'email': user.email,
            }
        )

    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    if request.method == 'GET':
        data = StudentProfileSerializer(student_profile).data
        data['role'] = 'student'
        data['name'] = data.get('full_name') or data.get('username')
        return Response(data)

    user = student_profile.user
    new_name = (request.data.get('name') or user.get_full_name() or user.username).strip()
    new_email = (request.data.get('email') or '').strip()
    new_phone = (request.data.get('phone') or '').strip()
    new_branch = (request.data.get('branch') or '').strip()
    new_cgpa = request.data.get('cgpa')
    new_year = request.data.get('year')

    if new_cgpa in (None, '') or new_year in (None, ''):
        return Response({'error': 'cgpa and year are required'}, status=400)

    try:
        student_profile.cgpa = float(new_cgpa)
        student_profile.year = int(new_year)
    except (TypeError, ValueError):
        return Response({'error': 'cgpa or year is invalid'}, status=400)

    student_profile.phone = new_phone
    student_profile.branch = new_branch
    student_profile.save()

    name_parts = new_name.split(maxsplit=1)
    user.first_name = name_parts[0] if name_parts else ''
    user.last_name = name_parts[1] if len(name_parts) > 1 else ''
    user.email = new_email
    user.save()

    data = StudentProfileSerializer(student_profile).data
    data['role'] = 'student'
    data['name'] = data.get('full_name') or data.get('username')
    return Response(data)


@api_view(['POST'])
def login_student(request):
    username = (request.data.get("username") or "").strip()
    password = request.data.get("password")

    if not username or not password:
        return Response({"error": "username and password are required"}, status=400)

    user = authenticate(request, username=username, password=password)

    if user is None:
        return Response({"error": "Invalid credentials"}, status=401)

    if user.is_staff or user.is_superuser:
        return Response(
            {
                "role": "admin",
                "username": user.username,
                "full_name": user.get_full_name() or user.username,
                "email": user.email,
            }
        )

    try:
        student_profile = StudentProfile.objects.select_related("user").get(user=user)
    except StudentProfile.DoesNotExist:
        return Response({"error": "Student profile not found"}, status=404)

    return Response(
        {
            "role": "student",
            "student_id": student_profile.id,
            "username": user.username,
            "full_name": user.get_full_name() or user.username,
            "email": user.email,
        }
    )


@api_view(['GET'])
def landing_summary(request):
    total_students_placed = Application.objects.filter(status='Accepted').values(
        'student'
    ).distinct().count()
    total_companies = Job.objects.values('company').distinct().count()
    highest_package = Job.objects.order_by('-package').values_list('package', flat=True).first() or 0
    featured_companies = list(
        Job.objects.values('company')
        .annotate(
            job_count=Count('id'),
            applicant_count=Count('application', distinct=True),
            highest_package_lpa=Max('package'),
        )
        .order_by('-highest_package_lpa', '-applicant_count', 'company')[:4]
    )

    return Response(
        {
            'hero': {
                'upcoming_drives': Job.objects.count(),
                'active_roles': Job.objects.count(),
                'interview_slots': Application.objects.filter(status='Selected').count(),
                'offer_calls': Application.objects.filter(
                    status__in=['Offered', 'Accepted']
                ).count(),
            },
            'outcomes': {
                'students_placed': total_students_placed,
                'placement_rate': 92,
                'highest_package_lpa': highest_package,
                'average_package_lpa': round(
                    Job.objects.aggregate(avg=Avg('package'))['avg'] or 0,
                    1,
                ),
                'companies_visited': total_companies,
            },
            'featured_companies': featured_companies,
        }
    )


@api_view(['GET'])
def get_jobs(request):
    student_profile = _resolve_student_profile_optional(request)
    jobs = Job.objects.all().order_by('-created_at')
    serializer = JobSerializer(
        jobs,
        many=True,
        context={"student_profile": student_profile},
    )
    return Response(serializer.data)


@api_view(['POST'])
def apply_job(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    if _has_accepted_offer(student_profile):
        return Response(
            {"error": "You have already accepted an offer. You cannot apply to more jobs."},
            status=400,
        )

    job_id = request.data.get("job_id")
    if not job_id:
        return Response({"error": "job_id is required"}, status=400)

    try:
        job = Job.objects.get(id=job_id)
    except Job.DoesNotExist:
        return Response({"error": "Job not found"}, status=404)

    application, created = Application.objects.get_or_create(
        student=student_profile,
        job=job,
    )

    if not created:
        return Response({"message": "Already applied"}, status=400)

    return Response({"message": "Application submitted"}, status=201)


@api_view(['GET'])
def my_applications(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    applications = Application.objects.filter(student=student_profile).select_related(
        "job"
    ).order_by("-applied_at")
    serializer = ApplicationSerializer(applications, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def my_bookmarks(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    bookmarks = Bookmark.objects.filter(student=student_profile).select_related(
        "job"
    ).order_by("-created_at")
    serializer = BookmarkSerializer(bookmarks, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def toggle_bookmark(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    job_id = request.data.get("job_id")
    if not job_id:
        return Response({"error": "job_id is required"}, status=400)

    try:
        job = Job.objects.get(id=job_id)
    except Job.DoesNotExist:
        return Response({"error": "Job not found"}, status=404)

    bookmark, created = Bookmark.objects.get_or_create(student=student_profile, job=job)
    if created:
        return Response({"message": "Job bookmarked", "bookmarked": True}, status=201)

    bookmark.delete()
    return Response({"message": "Bookmark removed", "bookmarked": False})


@api_view(['GET'])
def student_dashboard(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    applications = Application.objects.filter(student=student_profile).select_related("job")
    bookmarks = Bookmark.objects.filter(student=student_profile).select_related("job")
    applied_job_ids = applications.values_list("job_id", flat=True)
    accepted_application = applications.filter(status="Accepted").order_by("-applied_at").first()

    latest_jobs = Job.objects.exclude(id__in=applied_job_ids).order_by("-created_at")[:3]

    return Response(
        {
            "profile": StudentProfileSerializer(student_profile).data,
            "stats": {
                "applied_roles": applications.count(),
                "bookmarked_roles": bookmarks.count(),
                "shortlisted": applications.filter(
                    status__in=["Selected", "Offered", "Accepted"]
                ).count(),
                "pending_reviews": applications.filter(status="Pending").count(),
                "available_jobs": Job.objects.count(),
            },
            "recent_applications": ApplicationSerializer(
                applications.order_by("-applied_at")[:4],
                many=True,
            ).data,
            "recent_bookmarks": BookmarkSerializer(
                bookmarks.order_by("-created_at")[:4],
                many=True,
            ).data,
            "recommended_jobs": JobSerializer(
                latest_jobs,
                many=True,
                context={"student_profile": student_profile},
            ).data,
            "accepted_offer": ApplicationSerializer(accepted_application).data
            if accepted_application
            else None,
        }
    )


@api_view(['GET'])
def admin_dashboard(request):
    jobs = Job.objects.all()
    applications = Application.objects.select_related("job", "student", "student__user")

    return Response(
        {
            "stats": {
                "active_job_posts": jobs.count(),
                "total_applicants": applications.count(),
                "offered_students": applications.filter(
                    status__in=["Offered", "Accepted"]
                ).count(),
                "rejected_students": applications.filter(status="Rejected").count(),
            },
            "recent_jobs": JobSerializer(jobs.order_by("-created_at")[:5], many=True).data,
            "recent_applicants": AdminApplicationSerializer(
                applications.order_by("-applied_at")[:5],
                many=True,
            ).data,
        }
    )


@api_view(['GET', 'POST'])
def admin_jobs(request):
    if request.method == 'GET':
        jobs = Job.objects.all().order_by('-created_at')
        serializer = JobSerializer(jobs, many=True)
        return Response(serializer.data)

    serializer = JobCreateSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)

    job = serializer.save()
    return Response(JobSerializer(job).data, status=201)


@api_view(['DELETE'])
def admin_job_detail(request, job_id):
    try:
        job = Job.objects.get(id=job_id)
    except Job.DoesNotExist:
        return Response({'error': 'Job not found'}, status=404)

    job.delete()
    return Response({'message': 'Job deleted'})


@api_view(['GET'])
def admin_applicants(request):
    search = (request.query_params.get('search') or '').strip()
    applications = Application.objects.select_related(
        'job',
        'student',
        'student__user',
    ).order_by('-applied_at')

    if search:
        applications = applications.filter(
            Q(student__user__first_name__icontains=search)
            | Q(student__user__last_name__icontains=search)
            | Q(student__user__username__icontains=search)
            | Q(job__company__icontains=search)
            | Q(job__title__icontains=search)
        )

    return Response(AdminApplicationSerializer(applications, many=True).data)


@api_view(['GET', 'PATCH'])
def admin_application_detail(request, application_id):
    try:
        application = Application.objects.select_related(
            'job',
            'student',
            'student__user',
        ).get(id=application_id)
    except Application.DoesNotExist:
        return Response({'error': 'Application not found'}, status=404)

    if request.method == 'GET':
        return Response(
            {
                'application': AdminApplicationSerializer(application).data,
                'profile': StudentProfileSerializer(application.student).data,
                'status_choices': [choice[0] for choice in Application.STATUS_CHOICES],
            }
        )

    status_value = request.data.get('status')
    valid_statuses = [choice[0] for choice in Application.STATUS_CHOICES]
    if status_value not in valid_statuses:
        return Response(
            {
                'error': 'Invalid status',
                'valid_statuses': valid_statuses,
            },
            status=400,
        )

    application.status = status_value
    application.save(update_fields=['status'])
    return Response(AdminApplicationSerializer(application).data)


@api_view(['POST'])
def respond_to_offer(request, application_id):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    decision = (request.data.get('decision') or '').strip().lower()
    if decision not in {'accept', 'reject'}:
        return Response({'error': 'decision must be accept or reject'}, status=400)

    try:
        application = Application.objects.select_related('job').get(
            id=application_id,
            student=student_profile,
        )
    except Application.DoesNotExist:
        return Response({'error': 'Application not found'}, status=404)

    if application.status != 'Offered':
        return Response(
            {'error': 'Only offered applications can be accepted or rejected.'},
            status=400,
        )

    if decision == 'accept':
        if _has_accepted_offer(student_profile):
            return Response(
                {'error': 'You have already accepted another offer.'},
                status=400,
            )

        application.status = 'Accepted'
        application.save(update_fields=['status'])
        Application.objects.filter(student=student_profile).exclude(id=application.id).exclude(
            status='Accepted'
        ).update(status='Rejected')
        return Response({'message': 'Offer accepted'})

    application.status = 'Rejected'
    application.save(update_fields=['status'])
    return Response({'message': 'Offer rejected'})


@api_view(['GET'])
def admin_companies(request):
    companies = (
        Job.objects.values('company')
        .annotate(
            total_jobs=Count('id'),
            total_applications=Count('application', distinct=True),
            offered_count=Count('application', filter=Q(application__status='Offered')),
            rejected_count=Count('application', filter=Q(application__status='Rejected')),
            pending_count=Count('application', filter=Q(application__status='Pending')),
        )
        .order_by('company')
    )

    return Response(list(companies))
