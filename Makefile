install:
	cd src; bundle install

build:
	cd src; bundle exec jekyll build -b /marooned/ -d ../marooned

develop:
	cd src; bundle exec jekyll serve --drafts
