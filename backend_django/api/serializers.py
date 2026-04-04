from rest_framework import serializers
from .models import Application, Bookmark, Job, StudentProfile


class JobSerializer(serializers.ModelSerializer):
    is_applied = serializers.SerializerMethodField()
    is_bookmarked = serializers.SerializerMethodField()

    class Meta:
        model = Job
        fields = '__all__'

    def _student_profile(self):
        return self.context.get('student_profile')

    def get_is_applied(self, obj):
        student_profile = self._student_profile()
        if student_profile is None:
            return False
        return Application.objects.filter(student=student_profile, job=obj).exists()

    def get_is_bookmarked(self, obj):
        student_profile = self._student_profile()
        if student_profile is None:
            return False
        return Bookmark.objects.filter(student=student_profile, job=obj).exists()


class ApplicationSerializer(serializers.ModelSerializer):
    job_title = serializers.CharField(source='job.title', read_only=True)
    company = serializers.CharField(source='job.company', read_only=True)
    location = serializers.CharField(source='job.location', read_only=True)
    package = serializers.IntegerField(source='job.package', read_only=True)
    deadline = serializers.DateField(source='job.deadline', read_only=True)

    class Meta:
        model = Application
        fields = [
            'id',
            'student',
            'job',
            'status',
            'applied_at',
            'job_title',
            'company',
            'location',
            'package',
            'deadline',
        ]


class StudentProfileSerializer(serializers.ModelSerializer):
    graduation_year = serializers.IntegerField(source='year', read_only=True)
    full_name = serializers.CharField(source='user.get_full_name', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = StudentProfile
        fields = [
            'id',
            'user',
            'username',
            'full_name',
            'email',
            'phone',
            'branch',
            'cgpa',
            'year',
            'graduation_year',
        ]


class BookmarkSerializer(serializers.ModelSerializer):
    job_title = serializers.CharField(source='job.title', read_only=True)
    company = serializers.CharField(source='job.company', read_only=True)
    location = serializers.CharField(source='job.location', read_only=True)
    description = serializers.CharField(source='job.description', read_only=True)
    package = serializers.IntegerField(source='job.package', read_only=True)
    deadline = serializers.DateField(source='job.deadline', read_only=True)

    class Meta:
        model = Bookmark
        fields = [
            'id',
            'student',
            'job',
            'created_at',
            'job_title',
            'company',
            'location',
            'description',
            'package',
            'deadline',
        ]


class JobCreateSerializer(serializers.ModelSerializer):
    def validate_package(self, value):
        if value <= 0:
            raise serializers.ValidationError('Package must be greater than 0.')
        return value

    def validate_deadline(self, value):
        from django.utils import timezone

        if value < timezone.localdate():
            raise serializers.ValidationError('Deadline cannot be in the past.')
        return value

    class Meta:
        model = Job
        fields = [
            'id',
            'title',
            'company',
            'location',
            'description',
            'package',
            'deadline',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class AdminApplicationSerializer(serializers.ModelSerializer):
    job_title = serializers.CharField(source='job.title', read_only=True)
    company = serializers.CharField(source='job.company', read_only=True)
    location = serializers.CharField(source='job.location', read_only=True)
    package = serializers.IntegerField(source='job.package', read_only=True)
    deadline = serializers.DateField(source='job.deadline', read_only=True)
    student_name = serializers.SerializerMethodField()
    student_email = serializers.EmailField(source='student.user.email', read_only=True)
    student_phone = serializers.CharField(source='student.phone', read_only=True)
    branch = serializers.CharField(source='student.branch', read_only=True)
    cgpa = serializers.FloatField(source='student.cgpa', read_only=True)
    year = serializers.IntegerField(source='student.year', read_only=True)

    class Meta:
        model = Application
        fields = [
            'id',
            'student',
            'job',
            'status',
            'applied_at',
            'job_title',
            'company',
            'location',
            'package',
            'deadline',
            'student_name',
            'student_email',
            'student_phone',
            'branch',
            'cgpa',
            'year',
        ]

    def get_student_name(self, obj):
        return obj.student.user.get_full_name() or obj.student.user.username
