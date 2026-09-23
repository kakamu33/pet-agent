"""Entry point for scheduled jobs.

Future jobs: pre-generate daily learning content, deliver reminders, and run weekly reviews.
The worker calls the backend's domain services rather than duplicating product rules.
"""


def run() -> None:
    print("Pet Agent worker is ready. Configure a queue scheduler to register jobs.")


if __name__ == "__main__":
    run()

