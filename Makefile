default:	all

all:	game demo unerase doc

unerase:	Dist/Meteoroid.Unerase.zip

publish:	demo game doc unerase Dist/Meteoroid.Source.tar.gz
	@until rsync -essh --progress \
		Dist/Meteoroid.Demo.NTSC.a26 Dist/Meteoroid.Demo.PAL.a26 Dist/Meteoroid.Demo.SECAM.a26 \
		Dist/Meteoroid.Demo.zip Dist/Meteoroid.Source.tar.gz \
		Dist/Meteoroid.Demo.NTSC.pdf Dist/Meteoroid.Demo.PAL.pdf Dist/Meteoroid.Demo.SECAM.pdf \
		Dist/Meteoroid.Demo.NTSC-book.pdf \
		Dist/Meteoroid.Demo.PAL-book.pdf \
		Dist/Meteoroid.Demo.SECAM-book.pdf \
		Dist/Meteoroid.NTSC.a26 Dist/Meteoroid.PAL.a26 Dist/Meteoroid.SECAM.a26 \
		Dist/Meteoroid.NTSC.pdf Dist/Meteoroid.PAL.pdf Dist/Meteoroid.SECAM.pdf \
		Dist/Meteoroid.Unerase.NTSC.a26 \
		Dist/Meteoroid.Unerase.PAL.a26 \
		Dist/Meteoroid.Unerase.SECAM.a26 \
		star-hope.org:star-hope.org/games/Meteoroid/ ; \
	do sleep 1; done

plus:	game demo
	@echo 'put Dist/Meteoroid.NTSC.a26 Meteoroid.NTSC.EFSC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.PAL.a26 Meteoroid.PAL.EFSC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.SECAM.a26 Meteoroid.SECAM.EFSC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Demo.NTSC.a26 Meteoroid.Demo.NTSC.F4SC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Demo.PAL.a26 Meteoroid.Demo.PAL.F4SC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Demo.SECAM.a26 Meteoroid.Demo.SECAM.F4SC' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Unerase.NTSC.a26 Meteoroid.Unerase.NTSC.a26' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Unerase.PAL.a26 Meteoroid.Unerase.PAL.a26' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Unerase.SECAM.a26 Meteoroid.Unerase.SECAM.a26' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid
	@echo 'put Dist/Meteoroid.Manual.txt Meteoroid.Manual.txt' | cadaver https://plusstore.firmaplus.de/remote.php/dav/files/brpocock/Meteoroid

demo:	Dist/Meteoroid.Demo.zip

Dist/Meteoroid.Source.tar.gz:	game
	find Source Manual -name \*~ -exec rm {} \;
	tar zcf $@ Makefile README.md Source Manual

cart:	cart-ntsc

cart-ntsc:	Dist/Meteoroid.Demo.NTSC.a26
	minipro -p AT27C256@DIP28 -w $<

cart-pal:	Dist/Meteoroid.Demo.PAL.a26
	minipro -p AT27C256@DIP28 -w $<

cart-secam:	Dist/Meteoroid.Demo.SECAM.a26
	minipro -p AT27C256@DIP28 -w $<

# Basic Harmony cart only can handle 32k images
HARMONY=/run/media/${USER}/HARMONY/
harmony:	Dist/Meteoroid.Demo.NTSC.a26 \
		Dist/Meteoroid.NTSC.a26 \
		Dist/Meteoroid.Unerase.NTSC.a26
	@if [ $$(uname -s) = 'Linux' ] ; then \
	  cp -v Dist/Meteoroid.Demo.NTSC.a26 $(HARMONY)/Meteoroid/Demo.NTSC.a26 ;\
	  cp -v Dist/Meteoroid.NTSC.a26 $(HARMONY)/Meteoroid/Meteoroid.NTSC.a26 ;\
	  cp -v Dist/Meteoroid.Unerase.NTSC.a26 $(HARMONY)/Meteoroid/Unerase.NTSC.a26 ;\
	else \
	  echo "Patch Makefile for your $$(uname -s) OS" ; \
	fi

# Uno needs special extension to detect  us as an EF cartridge and shows
# fairyl short names only
UNOCART=/run/media/${USER}/TBA_2600/
uno:	Dist/Meteoroid.NTSC.a26 \
	Dist/Meteoroid.Demo.NTSC.a26 \
	Dist/Meteoroid.Unerase.NTSC.a26
	@if [ $$(uname -s) = 'Linux' ] ; then \
	  mkdir -p $(UNOCART)/METEOROID/ ;\
	  cp -v Dist/Meteoroid.NTSC.a26 $(UNOCART)/METEOROID/METEOROID.NTSC.a26 ;\
	  cp -v Dist/Meteoroid.Demo.NTSC.a26 $(UNOCART)/METEOROID/DEMO.NTSC.a26 ;\
	  cp -v Dist/Meteoroid.Unerase.NTSC.a26 $(UNOCART)/METEOROID/UNERASE.NTSC.a26 ;\
	else \
	  echo "Patch Makefile for your $$(uname -s) OS" ; \
	fi

Dist/Meteoroid.AtariAge.zip:	\
	Dist/Meteoroid.NTSC.a26 Dist/Meteoroid.PAL.a26 Dist/Meteoroid.SECAM.a26 \
	Dist/Meteoroid.NTSC.pro Dist/Meteoroid.PAL.pro Dist/Meteoroid.SECAM.pro \
	Dist/Meteoroid.NTSC.pdf Dist/Meteoroid.PAL.pdf Dist/Meteoroid.SECAM.pdf \
	Dist/Meteoroid.NTSC-book.pdf Dist/Meteoroid.PAL-book.pdf Dist/Meteoroid.SECAM-book.pdf
	zip $@ $^

Dist/Meteoroid.Unerase.zip: Dist/Meteoroid.Unerase.NTSC.a26 \
		Dist/Meteoroid.Unerase.PAL.a26 \
		Dist/Meteoroid.Unerase.SECAM.a26
	zip $@ $^

Dist/Meteoroid.Demo.zip: \
	Dist/Meteoroid.Demo.NTSC.a26 \
	Dist/Meteoroid.Demo.PAL.a26 \
	Dist/Meteoroid.Demo.SECAM.a26 \
	Dist/Meteoroid.Demo.NTSC.pro \
	Dist/Meteoroid.Demo.PAL.pro \
	Dist/Meteoroid.Demo.SECAM.pro \
	Dist/Meteoroid.Demo.NTSC.pdf \
	Dist/Meteoroid.Demo.PAL.pdf \
	Dist/Meteoroid.Demo.SECAM.pdf \
	Dist/Meteoroid.Demo.NTSC-book.pdf \
	Dist/Meteoroid.Demo.PAL-book.pdf \
	Dist/Meteoroid.Demo.SECAM-book.pdf
	zip $@ $^

game:	Dist/Meteoroid.AtariAge.zip

doc:	Dist/Meteoroid.NTSC.pdf Dist/Meteoroid.PAL.pdf Dist/Meteoroid.SECAM.pdf \
	Dist/Meteoroid.NTSC-book.pdf Dist/Meteoroid.PAL-book.pdf Dist/Meteoroid.SECAM-book.pdf \
	Dist/Meteoroid.Demo.NTSC.pdf Dist/Meteoroid.Demo.PAL.pdf Dist/Meteoroid.Demo.SECAM.pdf \
	Dist/Meteoroid.Demo.NTSC-book.pdf \
	Dist/Meteoroid.Demo.PAL-book.pdf \
	Dist/Meteoroid.Demo.SECAM-book.pdf \
	Dist/Meteoroid.Manual.txt \
	Dist/Meteoroid.Unerase.pdf

.PRECIOUS: %.s %.png %.a26 %.txt %.zip %.tar.gz

SOURCES=$(shell find Source -name \*.s -o -name \*.txt -o -name \*.png -o -name \*.midi -a -not -name .\#\*)

Dist/Meteoroid.Manual.txt:	Manual/Manual.txt
	cp Manual/Manual.txt Dist/Meteoroid.Manual.txt

Dist/Meteoroid.Demo.NTSC.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.Demo.NTSC.a26

Dist/Meteoroid.Demo.PAL.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.Demo.PAL.a26

Dist/Meteoroid.Demo.SECAM.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.Demo.SECAM.a26

Dist/Meteoroid.NTSC.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.NTSC.a26

Dist/Meteoroid.PAL.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.PAL.a26

Dist/Meteoroid.SECAM.a26:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Meteoroid.SECAM.a26

Source/Generated/Makefile:	bin/write-master-makefile ${SOURCES}
	mkdir -p Source/Generated
	bin/make-speakjet-enums 4
	$< > Source/Generated/Makefile

Dist/Meteoroid.NTSC-book.pdf:	Dist/Meteoroid.NTSC.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.PAL-book.pdf:	Dist/Meteoroid.PAL.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.SECAM-book.pdf:	Dist/Meteoroid.SECAM.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.Demo.NTSC-book.pdf:	Dist/Meteoroid.Demo.NTSC.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.Demo.PAL-book.pdf:	Dist/Meteoroid.Demo.PAL.pdf
	pdfbook2 --paper=a4 -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.Demo.SECAM-book.pdf:	Dist/Meteoroid.Demo.SECAM.pdf
	pdfbook2 --paper=a4 -o 0 -i 0 -t 0 -b 0 $<

Dist/Meteoroid.Unerase.pdf:	Manual/Unerase.tex
	mkdir -p Object/Unerase.pdf
	cp $< Object/Unerase.pdf/
	ln -sf ../Manual Object/
	-cd Object/Unerase.pdf ; xelatex -interaction=batchmode Unerase.tex
	-cd Object/Unerase.pdf ; xelatex -interaction=batchmode Unerase.tex
	-cd Object/Unerase.pdf ; xelatex -interaction=batchmode Unerase.tex
	mkdir -p Dist
	mv Object/Unerase.pdf/Unerase.pdf Dist/Meteoroid.Unerase.pdf

Dist/Meteoroid.NTSC.pdf: Manual/Meteoroid.tex
	mkdir -p Object/NTSC.pdf
	cp $< Object/NTSC.pdf/
	ln -sf ../Manual Object/
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Meteoroid}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Meteoroid}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/NTSC.pdf/Meteoroid.pdf Dist/Meteoroid.NTSC.pdf

Dist/Meteoroid.PAL.pdf: Manual/Meteoroid.tex
	mkdir -p Object/PAL.pdf
	cp $< Object/PAL.pdf/
	ln -sf ../Manual Object/
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Meteoroid}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Meteoroid}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/PAL.pdf/Meteoroid.pdf Dist/Meteoroid.PAL.pdf

Dist/Meteoroid.SECAM.pdf: Manual/Meteoroid.tex
	mkdir -p Object/SECAM.pdf
	cp $< Object/SECAM.pdf/
	ln -sf ../Manual Object/
	-cd Object/SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\input{Meteoroid}"
	-cd Object/SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\input{Meteoroid}"
	-cd Object/SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/SECAM.pdf/Meteoroid.pdf Dist/Meteoroid.SECAM.pdf

Dist/Meteoroid.Demo.NTSC.pdf: Manual/Meteoroid.tex
	mkdir -p Object/Demo.NTSC.pdf
	cp $< Object/Demo.NTSC.pdf/
	ln -sf ../Manual Object/
	-cd Object/Demo.NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/Demo.NTSC.pdf/Meteoroid.pdf Dist/Meteoroid.Demo.NTSC.pdf

Dist/Meteoroid.Demo.PAL.pdf: Manual/Meteoroid.tex
	mkdir -p Object/Demo.PAL.pdf
	cp $< Object/Demo.PAL.pdf/
	ln -sf ../Manual Object/
	-cd Object/Demo.PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/Demo.PAL.pdf/Meteoroid.pdf Dist/Meteoroid.Demo.PAL.pdf

Dist/Meteoroid.Demo.SECAM.pdf: Manual/Meteoroid.tex
	mkdir -p Object/Demo.SECAM.pdf
	cp $< Object/Demo.SECAM.pdf/
	ln -sf ../Manual Object/
	-cd Object/Demo.SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\def\DEMO{}\input{Meteoroid}"
	-cd Object/Demo.SECAM.pdf ; xelatex -interaction=batchmode "\def\TVSECAM{}\def\DEMO{}\input{Meteoroid}"
	mkdir -p Dist
	mv Object/Demo.SECAM.pdf/Meteoroid.pdf Dist/Meteoroid.Demo.SECAM.pdf

# If Make tries to second-guess us, let the default assembler be “error,”
# because the default assembler (probably GNU gas) almost certainly
# neither understands 65xx mnemonics nor 64tass macros and things.
AS=error

Dist/Meteoroid.Demo.NTSC.sym:	\
	$(shell bin/banks Object Demo.NTSC.sym)
	cat $^ > $@

Dist/Meteoroid.Demo.PAL.sym:	\
	$(shell bin/banks Object Demo.PAL.sym)
	cat $^ > $@

Dist/Meteoroid.Demo.SECAM.sym:	\
	$(shell bin/banks Object Demo.SECAM.sym)
	cat $^ > $@

Dist/Meteoroid.NTSC.sym:	\
	$(shell bin/banks Object NTSC.sym)
	cat $^ > $@

Dist/Meteoroid.PAL.sym:	\
	$(shell bin/banks Object PAL.sym)
	cat $^ > $@

Dist/Meteoroid.SECAM.sym:	\
	$(shell bin/banks Object SECAM.sym)
	cat $^ > $@


Dist/Meteoroid.Demo.NTSC.pro:	Source/Meteoroid.Demo.pro Dist/Meteoroid.Demo.NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.Demo.NTSC.a26 | cut -d\  -f1)/g > $@

Dist/Meteoroid.Demo.PAL.pro:	Source/Meteoroid.Demo.pro Dist/Meteoroid.Demo.PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.Demo.PAL.a26 | cut -d\  -f1)/g > $@

Dist/Meteoroid.Demo.SECAM.pro:	Source/Meteoroid.Demo.pro Dist/Meteoroid.Demo.SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.Demo.SECAM.a26 | cut -d\  -f1)/g > $@

Dist/Meteoroid.NTSC.pro:	Source/Meteoroid.pro Dist/Meteoroid.NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.NTSC.a26 | cut -d\  -f1)/g > $@

Dist/Meteoroid.PAL.pro:	Source/Meteoroid.pro Dist/Meteoroid.PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.PAL.a26 | cut -d\  -f1)/g > $@

Dist/Meteoroid.SECAM.pro:	Source/Meteoroid.pro Dist/Meteoroid.SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/Meteoroid.SECAM.a26 | cut -d\  -f1)/g > $@

dstella:	Dist/Meteoroid.Demo.NTSC.a26 Dist/Meteoroid.Demo.NTSC.sym Dist/Meteoroid.Demo.NTSC.pro
	stella -tv.filter 3 -grabmouse 0 -bs F4SC \
		-lc Genesis -rc AtariVox \
		-format NTSC -pp Yes \
		-debug $<

dstella-pal:	Dist/Meteoroid.Demo.PAL.a26 Dist/Meteoroid.Demo.PAL.sym Dist/Meteoroid.Demo.PAL.pro
	stella -tv.filter 3 -grabmouse 0 -bs F4SC \
		-lc Genesis -rc AtariVox \
		-format PAL -pp Yes \
		-debug $<

dstella-secam:	Dist/Meteoroid.Demo.SECAM.a26 Dist/Meteoroid.Demo.SECAM.sym Dist/Meteoroid.Demo.SECAM.pro
	stella -tv.filter 3 -grabmouse 0 -bs F4SC \
		-lc Genesis -rc AtariVox \
		-format SECAM -pp Yes \
		-debug $<

stella:	Dist/Meteoroid.NTSC.a26 Dist/Meteoroid.NTSC.sym Dist/Meteoroid.NTSC.pro
	stella -tv.filter 3 -grabmouse 0 -bs EFSC \
		-lc Genesis -rc AtariVox \
		-format NTSC -pp Yes \
		-debug $<

stella-pal:	Dist/Meteoroid.PAL.a26 Dist/Meteoroid.PAL.sym Dist/Meteoroid.PAL.pro
	stella -tv.filter 3 -grabmouse 0 -bs EFSC \
		-lc Genesis -rc AtariVox \
		-format PAL -pp Yes \
		-debug $<

stella-secam:	Dist/Meteoroid.SECAM.a26 Dist/Meteoroid.SECAM.sym Dist/Meteoroid.SECAM.pro
	stella -tv.filter 3 -grabmouse 0 -bs EFSC \
		-lc Genesis -rc AtariVox \
		-format SECAM -pp Yes \
		-debug $<

quickclean:
	rm -rf Object Dist Source/Generated

clean:
	rm -fr Object Dist Source/Generated bin/buildapp bin/skyline-tool

bin/skyline-tool:	bin/buildapp \
	$(shell ls SkylineTool/*.lisp SkylineTool/src/*.lisp SkylineTool/skyline-tool.asd)
	mkdir -p bin
	@echo "Note: This may take a while if you don't have some common Quicklisp \
libraries already compiled. On subsequent runs, though, it'll be much quicker." >&2
	bin/buildapp --output bin/skyline-tool \
		--load SkylineTool/setup.lisp \
		--load-system skyline-tool \
		--entry skyline-tool::command

bin/buildapp:
	sbcl --load SkylineTool/prepare-system.lisp --eval '(cl-user::quit)'


Dist/Meteoroid.Unerase.NTSC.a26:	$(shell find Source -name \*.s)
	64tass --nostart --long-branch --case-sensitive \
	--ascii -I. -I Source/Common -I Source/Routines \
	-Wall -Wno-shadow -Wno-leading-zeros --m6502 \
	Source/Unerase/Unerase.s -DTV=NTSC -o $@

Dist/Meteoroid.Unerase.PAL.a26:	$(shell find Source -name \*.s)
	64tass --nostart --long-branch --case-sensitive \
	--ascii -I. -I Source/Common -I Source/Routines \
	-Wall -Wno-shadow -Wno-leading-zeros --m6502 \
	Source/Unerase/Unerase.s -DTV=PAL -o $@

Dist/Meteoroid.Unerase.SECAM.a26:	$(shell find Source -name \*.s)
	64tass --nostart --long-branch --case-sensitive \
	--ascii -I. -I Source/Common -I Source/Routines \
	-Wall -Wno-shadow -Wno-leading-zeros --m6502 \
	Source/Unerase/Unerase.s -DTV=SECAM -o $@

RELEASE=noreleasenamegiven
release:	all
	@if [ $(RELEASE) = noreleasenamegiven ]; then echo "Usage: make RELEASE=ident release" >&2; exit 1; fi
	mkdir -p Dist/$(RELEASE)
	-rm Dist/$(RELEASE)/*
	-cp -v Dist/Meteoroid.{Demo.,Unerase.}{NTSC,PAL,SECAM}.{a26,pro} \
		Dist/Meteoroid.{Demo.{NTSC,PAL,SECAM},Unerase}.pdf \
		Dist/$(RELEASE) 2>/dev/null
	cp -v Dist/Meteoroid.{NTSC,PAL,SECAM}{,-book}.pdf Dist/$(RELEASE)
	cp -v Dist/Meteoroid.Manual.txt Dist/$(RELEASE)
	@cd Dist/$(RELEASE) ; \
	for file in Meteoroid.*.{zip,a26,pdf}; do \
		mv -v $$file $$(echo $$file | perl -pne 's(Meteoroid.([^.]+).(.*)) (Meteoroid.\1.$(RELEASE).\2)'); \
	done
	@echo "AtariAge Release $(RELEASE) of Meteoroid for the Atari 2600. © 2021 Bruce-Robert Pocock." | \
		zip -9 Dist/$(RELEASE)/Meteoroid.AtariAge.$(RELEASE).zip \
		Dist/$(RELEASE)/Meteoroid.* Dist/$(RELEASE)/Meteoroid.{NTSC,PAL,SECAM}*pdf
	@echo "Demo Release $(RELEASE) of Meteoroid for the Atari 2600. © 2021 Bruce-Robert Pocock." | \
		zip -9 Dist/$(RELEASE)/Meteoroid.Demo.$(RELEASE).zip \
		Dist/$(RELEASE)/Meteoroid.Demo.*{a26,pdf,pro}
	@echo "Unerase Tool Release $(RELEASE) of Meteoroid for the Atari 2600. © 2021 Bruce-Robert Pocock." | \
		zip -9 Dist/$(RELEASE)/Meteoroid.Unerase.$(RELEASE).zip \
		Dist/$(RELEASE)/Meteoroid.Unerase.*{a26,pdf,pro}

publish-release:	release
	until rsync -essh -v Dist/$(RELEASE)/*$(RELEASE)* \
		star-hope.org:star-hope.org/games/Meteoroid ; \
		sleep 1 ; done
