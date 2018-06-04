.PHONY: main clean docker

main:
	rm -f .coqdeps.d Makefile.coq Makefile.coq.conf _CoqProjectFull
	echo '-R coq Main' > _CoqProjectFull
	find coq -type f -name '*.v' >> _CoqProjectFull
	coq_makefile -f _CoqProjectFull -o Makefile.coq || \
	  (rm -f .coqdeps.d Makefile.coq Makefile.coq.conf _CoqProjectFull; exit 1)
	make -f Makefile.coq || \
	  (rm -f .coqdeps.d Makefile.coq Makefile.coq.conf _CoqProjectFull; exit 1)
	rm -f .coqdeps.d Makefile.coq Makefile.coq.conf _CoqProjectFull

clean:
	rm -f _CoqProjectFull Makefile.coq \
	  $(shell \
	    find . -type d \( \
	      -path ./.git \
	    \) -prune -o \( \
	      -name '*.aux' -o \
	      -name '*.glob' -o \
	      -name '*.vo' -o \
	      -name '.coqdeps.d' -o \
	      -name 'Makefile.coq' -o \
	      -name 'Makefile.coq.conf' -o \
	      -name '_CoqProjectFull' \
	    \) -print \
	  )

docker:
	CONTAINER="$$( \
	  docker create --rm --user=root stephanmisc/coq:8.8.0 bash -c ' \
	    chown -R user:user repo && \
	    su user -s /bin/bash -l -c \
	      "cd repo && make clean && make main" \
	  ' \
	)" && \
	docker cp . "$$CONTAINER:/home/user/repo" && \
	docker start --attach "$$CONTAINER"
