from django.urls import path
from . import views

urlpatterns = [
    path('landing-summary/', views.landing_summary),
    path('login/', views.login_student),
    path('profile/', views.user_profile),
    path('student-dashboard/', views.student_dashboard),
    path('jobs/', views.get_jobs),
    path('apply/', views.apply_job),
    path('my-applications/', views.my_applications),
    path('my-applications/<int:application_id>/respond/', views.respond_to_offer),
    path('bookmarks/', views.my_bookmarks),
    path('toggle-bookmark/', views.toggle_bookmark),
    path('admin/dashboard/', views.admin_dashboard),
    path('admin/jobs/', views.admin_jobs),
    path('admin/jobs/<int:job_id>/', views.admin_job_detail),
    path('admin/applicants/', views.admin_applicants),
    path('admin/applications/<int:application_id>/', views.admin_application_detail),
    path('admin/companies/', views.admin_companies),
]
