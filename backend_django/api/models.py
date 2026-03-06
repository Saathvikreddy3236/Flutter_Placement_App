from django.db import models
from django.contrib.auth.models import User


# -------------------------------
# 1 Student Profile Model
# -------------------------------
class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone = models.CharField(max_length=15)
    branch = models.CharField(max_length=50)
    cgpa = models.FloatField()
    year = models.IntegerField()

    def __str__(self):
        return self.user.username


# -------------------------------
# 2 Job Model
# -------------------------------
class Job(models.Model):
    title = models.CharField(max_length=100)
    company = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    description = models.TextField()
    package = models.IntegerField(help_text="Package in LPA")
    deadline = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.company}"


# -------------------------------
# 3 Application Model
# -------------------------------
class Application(models.Model):
    STATUS_CHOICES = (
        ('Pending', 'Pending'),
        ('Selected', 'Selected'),
        ('Rejected', 'Rejected'),
    )

    student = models.ForeignKey(StudentProfile, on_delete=models.CASCADE)
    job = models.ForeignKey(Job, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    applied_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('student', 'job')  # Prevent duplicate applications

    def __str__(self):
        return f"{self.student.user.username} - {self.job.title}"

