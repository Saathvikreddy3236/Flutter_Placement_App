from datetime import date, timedelta

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from api.models import Application, Bookmark, Job, StudentProfile


class Command(BaseCommand):
    help = "Seed demo students, jobs, applications, and bookmarks for the placement portal."

    def handle(self, *args, **options):
        self._create_admin()
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
        self.stdout.write("Admin login: admin / admin123")
        self.stdout.write("Student login password for all demo students: demo123")

    def _create_admin(self):
        admin_user, created = User.objects.get_or_create(
            username="admin",
            defaults={
                "first_name": "Placement",
                "last_name": "Admin",
                "email": "admin@campus.example.com",
                "is_staff": True,
                "is_superuser": True,
            },
        )

        if not created:
            admin_user.first_name = "Placement"
            admin_user.last_name = "Admin"
            admin_user.email = "admin@campus.example.com"
            admin_user.is_staff = True
            admin_user.is_superuser = True

        admin_user.set_password("admin123")
        admin_user.save()

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
            {
                "title": "Frontend Developer",
                "company": "Freshworks",
                "location": "Chennai",
                "description": "Build polished web dashboards, work with APIs, and improve product usability.",
                "package": 9,
                "deadline": date.today() + timedelta(days=17),
            },
            {
                "title": "AI/ML Engineer",
                "company": "Cognizant",
                "location": "Bengaluru",
                "description": "Train ML pipelines, evaluate model performance, and support intelligent features.",
                "package": 11,
                "deadline": date.today() + timedelta(days=23),
            },
            {
                "title": "DevOps Associate",
                "company": "IBM",
                "location": "Pune",
                "description": "Maintain CI/CD pipelines, automate deployments, and support cloud environments.",
                "package": 7,
                "deadline": date.today() + timedelta(days=30),
            },
            {
                "title": "Cybersecurity Analyst",
                "company": "Deloitte",
                "location": "Gurugram",
                "description": "Monitor security alerts, investigate incidents, and support compliance workflows.",
                "package": 8,
                "deadline": date.today() + timedelta(days=21),
            },
            {
                "title": "Product Support Engineer",
                "company": "Capgemini",
                "location": "Noida",
                "description": "Handle product support cases, debug customer issues, and document fixes.",
                "package": 6,
                "deadline": date.today() + timedelta(days=19),
            },
            {
                "title": "Mobile App Developer",
                "company": "Paytm",
                "location": "Bengaluru",
                "description": "Develop mobile product features, optimize performance, and ship reliable builds.",
                "package": 10,
                "deadline": date.today() + timedelta(days=26),
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
            {
                "username": "akash",
                "first_name": "Akash",
                "last_name": "Singh",
                "email": "akash.singh@example.com",
                "phone": "9876500017",
                "branch": "CSE",
                "cgpa": 8.9,
                "year": 2026,
            },
            {
                "username": "divya",
                "first_name": "Divya",
                "last_name": "Menon",
                "email": "divya.menon@example.com",
                "phone": "9876500018",
                "branch": "AIDS",
                "cgpa": 9.0,
                "year": 2025,
            },
            {
                "username": "nithin",
                "first_name": "Nithin",
                "last_name": "Kumar",
                "email": "nithin.kumar@example.com",
                "phone": "9876500019",
                "branch": "ECE",
                "cgpa": 7.8,
                "year": 2026,
            },
            {
                "username": "pooja",
                "first_name": "Pooja",
                "last_name": "Joshi",
                "email": "pooja.joshi@example.com",
                "phone": "9876500020",
                "branch": "IT",
                "cgpa": 8.5,
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
            ("akash", ("IBM", "DevOps Associate"), "Offered"),
            ("akash", ("Amazon", "Cloud Support Associate"), "Selected"),
            ("akash", ("Freshworks", "Frontend Developer"), "Pending"),
            ("divya", ("Cognizant", "AI/ML Engineer"), "Selected"),
            ("divya", ("Zoho", "Backend Developer"), "Pending"),
            ("divya", ("Paytm", "Mobile App Developer"), "Pending"),
            ("nithin", ("Capgemini", "Product Support Engineer"), "Rejected"),
            ("nithin", ("TCS", "Graduate Trainee Engineer"), "Pending"),
            ("pooja", ("Freshworks", "Frontend Developer"), "Offered"),
            ("pooja", ("Deloitte", "Cybersecurity Analyst"), "Pending"),
            ("pooja", ("IBM", "DevOps Associate"), "Selected"),
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
            ("rahul", ("Paytm", "Mobile App Developer")),
            ("akash", ("Deloitte", "Cybersecurity Analyst")),
            ("divya", ("Amazon", "Cloud Support Associate")),
            ("nithin", ("IBM", "DevOps Associate")),
            ("pooja", ("Cognizant", "AI/ML Engineer")),
        ]

        for username, job_key in bookmark_specs:
            Bookmark.objects.get_or_create(
                student=students[username],
                job=jobs[job_key],
            )
