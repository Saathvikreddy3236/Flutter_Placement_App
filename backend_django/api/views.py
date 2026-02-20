from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate
from .models import Job, Application, StudentProfile
from .serializers import JobSerializer, ApplicationSerializer


def _resolve_student_profile(request):
    if request.user and request.user.is_authenticated:
        try:
            return StudentProfile.objects.get(user=request.user), None
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


# -----------------------------
# LOGIN
# -----------------------------
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
        student_profile = StudentProfile.objects.get(user=user)
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


# -----------------------------
# GET ALL JOBS
# -----------------------------
@api_view(['GET'])
def get_jobs(request):
    jobs = Job.objects.all()
    serializer = JobSerializer(jobs, many=True)
    return Response(serializer.data)


# -----------------------------
# APPLY FOR JOB
# -----------------------------
@api_view(['POST'])
def apply_job(request):
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

    application, created = Application.objects.get_or_create(
        student=student_profile,
        job=job
    )

    if not created:
        return Response({"message": "Already applied"}, status=400)

    return Response({"message": "Application submitted"}, status=201)


# -----------------------------
# VIEW MY APPLICATIONS
# -----------------------------
@api_view(['GET'])
def my_applications(request):
    student_profile, error_response = _resolve_student_profile(request)
    if error_response:
        return error_response

    applications = Application.objects.filter(student=student_profile)
    serializer = ApplicationSerializer(applications, many=True)

    return Response(serializer.data)
