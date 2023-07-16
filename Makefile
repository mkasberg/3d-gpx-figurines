.PHONY: image bash clean

image:
	docker build -t 3d_course_miniature:latest .

bash: image
	docker run --rm -it -v ${PWD}:/root/project --workdir /root/project 3d_course_miniature:latest /bin/bash

clean:
	docker rmi 3d_course_miniature:latest
