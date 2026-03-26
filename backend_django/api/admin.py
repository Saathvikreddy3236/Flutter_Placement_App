from django.contrib import admin

from .models import Application, Bookmark, Job, StudentProfile

admin.site.register(StudentProfile)
admin.site.register(Job)
admin.site.register(Application)
admin.site.register(Bookmark)
