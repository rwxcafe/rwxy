help:
	@echo 'Usage: make [target]'
	@echo
	@echo 'Development Targets:'
	@echo '  venv      Create virtual Python environment for development.'
	@echo '  checks    Run linters and tests.'
	@echo
	@echo 'Deployment Targets:'
	@echo '  service   Remove, install, configure, and run app.'
	@echo '  rm        Remove app.'
	@echo '  help      Show this help message.'


# Development Targets
# -------------------

rmvenv:
	rm -rf ~/.venv/rwxy venv

venv: FORCE
	python3 -m venv ~/.venv/rwxy
	echo . ~/.venv/rwxy/bin/activate > venv
	. ./venv && pip3 install pylint pycodestyle pydocstyle pyflakes isort

lint:
	. ./venv && ! isort --quiet --diff . | grep .
	. ./venv && pycodestyle .
	. ./venv && pyflakes .
	. ./venv && pylint -d C0115,C0116,R0903,R0911,R0913,R0914,W0718 rwxy

test:
	python3 -m unittest -v

coverage:
	. ./venv && coverage run --branch -m unittest -v
	. ./venv && coverage report --show-missing
	. ./venv && coverage html

check-password:
	! grep -r '"password":' . | grep -vE '^\./[^/]*.json|Makefile|\.\.\.'

checks: lint test check-password

clean:
	rm -rf *.pyc __pycache__
	rm -rf .coverage htmlcov
	rm -rf dist rwxy.egg-info


# Deployment Targets
# ------------------

service: rmservice
	adduser --system --group --home / rwxy
	chown -R rwxy:rwxy .
	chmod 600 rwxy.json
	systemctl enable "$$PWD/etc/rwxy.service"
	systemctl daemon-reload
	systemctl start rwxy
	@echo Done; echo

rmservice:
	-systemctl stop rwxy
	-systemctl disable rwxy
	systemctl daemon-reload
	-deluser rwxy
	@echo Done; echo

FORCE:
