FROM python:3.8

# Install dependencies
RUN apt-get update && apt-get install -y python3-distutils build-essential

# Ensure pip and setuptools are up to date
RUN pip install --upgrade pip setuptools

# Install Django
RUN pip install django==3.2

# Copy application files into the container
COPY . .

# Run migrations
RUN python manage.py migrate

# Expose port for the app
EXPOSE 8000

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
