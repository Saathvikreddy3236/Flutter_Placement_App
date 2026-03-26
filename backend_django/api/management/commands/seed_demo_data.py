from datetime import date, timedelta

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from api.models import Application, Bookmark, Job, StudentProfile


class Command(BaseCommand):
    help = "Seed demo students, jobs, applications, and bookmarks for the placement portal."

    def handle(self, *args, **options):
        jobs = self._create_jobs()
        students = self._create_students()
        self._create_applications(students, jobs)
        self._create_bookmarks(students, jobs)

        self.stdout.write(
            self.style.SUCCESS(
                "Demo data ready: "
                f"{StudentProfile.objects.count()} students, "
                f"{Job.objects.count()} jobs, "
                f"{Application.objects.count()} applications, "
                f"{Bookmark.objects.count()} bookmarks."
            )
        )
        self.stdout.write("Student login password for all demo students: demo123")

    def _create_jobs(self):
        job_specs = [
            {
                "title": "Software Engineer Intern",
                "company": "Infosys",
                "location": "Bengaluru",
                "description": "Work on internal platforms, APIs, and debugging production-grade systems.",
                "package": 6,
                "deadline": date.today() + timedelta(days=18),
            },
            {
                "title": "Graduate Trainee Engineer",
                "company": "TCS",
                "location": "Hyderabad",
                "description": "Entry-level campus role focused on enterprise application development and support.",
                "package": 4,
                "deadline": date.today() + timedelta(days=25),
            },
            {
                "title": "Data Analyst",
                "company": "Wipro",
                "location": "Chennai",
                "description": "Analyze datasets, build dashboards, and support business reporting workflows.",
                "package": 5,
                "deadline": date.today() + timedelta(days=15),
            },
            {
                "title": "Backend Developer",
                "company": "Zoho",
                "location": "Chennai",
                "description": "Build backend services, optimize APIs, and maintain scalable application logic.",
                "package": 8,
                "deadline": date.today() + timedelta(days=12),
            },
            {
                "title": "Cloud Support Associate",
                "company": "Amazon",
                "location": "Hyderabad",
                "description": "Support cloud customers, troubleshoot infrastructure issues, and monitor service health.",
                "package": 10,
                "deadline": date.today() + timedelta(days=20),
            },
            {
                "title": "QA Automation Engineer",
                "company": "Accenture",
                "location": "Pune",
                "description": "Write test cases, automate regression suites, and improve release confidence.",
                "package": 5,
                "deadline": date.today() + timedelta(days=28),
            },
        ]

        jobs = {}
        for spec in job_specs:
            job, _ = Job.objects.update_or_create(
                title=spec["title"],
                company=spec["company"],
                defaults=spec,
            )
            jobs[(job.company, job.title)] = job
        return jobs

    def _create_students(self):
        student_specs = [
            {
                "username": "rahul",
                "first_name": "Rahul",
                "last_name": "Sharma",
                "email": "rahul.sharma@example.com",
                "phone": "9876500011",
                "branch": "CSE",
                "cgpa": 8.7,
                "year": 2025,
            },
            {
                "username": "priya",
                "first_name": "Priya",
                "last_name": "Reddy",
                "email": "priya.reddy@example.com",
                "phone": "9876500012",
                "branch": "ECE",
                "cgpa": 9.1,
                "year": 2025,
            },
            {
                "username": "arjun",
                "first_name": "Arjun",
                "last_name": "Patel",
                "email": "arjun.patel@example.com",
                "phone": "9876500013",
                "branch": "IT",
                "cgpa": 8.4,
                "year": 2026,
            },
            {
                "username": "sneha",
                "first_name": "Sneha",
                "last_name": "Iyer",
                "email": "sneha.iyer@example.com",
                "phone": "9876500014",
                "branch": "AIML",
                "cgpa": 9.3,
                "year": 2025,
            },
            {
                "username": "karthik",
                "first_name": "Karthik",
                "last_name": "Verma",
                "email": "karthik.verma@example.com",
                "phone": "9876500015",
                "branch": "MECH",
                "cgpa": 7.9,
                "year": 2026,
            },
            {
                "username": "meera",
                "first_name": "Meera",
                "last_name": "Nair",
                "email": "meera.nair@example.com",
                "phone": "9876500016",
                "branch": "EEE",
                "cgpa": 8.2,
                "year": 2025,
            },
        ]

        students = {}
        for spec in student_specs:
            user, _ = User.objects.update_or_create(
                username=spec["username"],
                defaults={
                    "first_name": spec["first_name"],
                    "last_name": spec["last_name"],
                    "email": spec["email"],
                    "is_staff": False,
                    "is_superuser": False,
                },
            )
            user.set_password("demo123")
            user.save(update_fields=["password"])

            profile, _ = StudentProfile.objects.update_or_create(
                user=user,
                defaults={
                    "phone": spec["phone"],
                    "branch": spec["branch"],
                    "cgpa": spec["cgpa"],
                    "year": spec["year"],
                },
            )
            students[spec["username"]] = profile
        return students

    def _create_applications(self, students, jobs):
        application_specs = [
            ("rahul", ("Zoho", "Backend Developer"), "Accepted"),
            ("rahul", ("Infosys", "Software Engineer Intern"), "Rejected"),
            ("rahul", ("Wipro", "Data Analyst"), "Rejected"),
            ("priya", ("Amazon", "Cloud Support Associate"), "Offered"),
            ("priya", ("TCS", "Graduate Trainee Engineer"), "Pending"),
            ("arjun", ("Infosys", "Software Engineer Intern"), "Pending"),
            ("arjun", ("Accenture", "QA Automation Engineer"), "Selected"),
            ("sneha", ("Zoho", "Backend Developer"), "Selected"),
            ("sneha", ("Amazon", "Cloud Support Associate"), "Pending"),
            ("karthik", ("TCS", "Graduate Trainee Engineer"), "Rejected"),
            ("karthik", ("Wipro", "Data Analyst"), "Pending"),
            ("meera", ("Accenture", "QA Automation Engineer"), "Rejected"),
            ("meera", ("Infosys", "Software Engineer Intern"), "Pending"),
        ]

        for username, job_key, status in application_specs:
            Application.objects.update_or_create(
                student=students[username],
                job=jobs[job_key],
                defaults={"status": status},
            )

    def _create_bookmarks(self, students, jobs):
        bookmark_specs = [
            ("priya", ("Zoho", "Backend Developer")),
            ("arjun", ("Amazon", "Cloud Support Associate")),
            ("sneha", ("Infosys", "Software Engineer Intern")),
            ("karthik", ("Accenture", "QA Automation Engineer")),
            ("meera", ("TCS", "Graduate Trainee Engineer")),
        ]

        for username, job_key in bookmark_specs:
            Bookmark.objects.get_or_create(
                student=students[username],
                job=jobs[job_key],
            )
