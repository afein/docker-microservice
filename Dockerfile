FROM python:2-onbuild

COPY . /src

EXPOSE 80
ENTRYPOINT ["python", "/src/service.py"]
