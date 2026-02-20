from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login_student),
    path('jobs/', views.get_jobs),
    path('apply/', views.apply_job),
    path('my-applications/', views.my_applications),
]
