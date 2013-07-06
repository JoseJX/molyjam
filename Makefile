RELEASE_NAME=test

LUA_FILES=main.lua ground.lua plane.lua conf.lua cabinview.lua caller.lua button.lua stewardess.lua bar.lua utils.lua player2.lua
GRAPHICS_FILES=graphics/*
SCRIPT_FILES=scripts/*

FILELIST=${LUA_FILES} ${GRAPHICS_FILES} ${SCRIPT_FILES}

all: love 

love:
	zip -9 -q -r ${RELEASE_NAME}.love ${FILELIST}		
	
test:
	love .

vtest:
	vglrun love .

commit:
	rm -f ${RELEASE_NAME}.love
	git add *

clean:
	rm -f ${RELEASE_NAME}.love	
