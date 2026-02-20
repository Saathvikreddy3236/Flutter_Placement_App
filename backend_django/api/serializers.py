from rest_framework import serializers
from .models import StudentProfile, Job, Application


class JobSerializer(serializers.ModelSerializer):
    class Meta:
        model = Job
        fields = '__all__'


class ApplicationSerializer(serializers.ModelSerializer):
    job_title = serializers.CharField(source='job.title', read_only=True)
    company = serializers.CharField(source='job.company', read_only=True)
    location = serializers.CharField(source='job.location', read_only=True)

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
        ]


class StudentProfileSerializer(serializers.ModelSerializer):
    graduation_year = serializers.IntegerField(source='year', read_only=True)

    class Meta:
        model = StudentProfile
        fields = '__all__'
