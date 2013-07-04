RELEASE_NAME=test

LUA_FILES=main.lua ground.lua plane.lua conf.lua cabinview.lua caller.lua button.lua stewardess.lua bar.lua utils.lua
DATA_FILES=plane.png cloud1.png cabin.png stewardess.png phone.png
SCRIPT_FILES=scripts/*

FILELIST=${LUA_FILES} ${DATA_FILES} ${SCRIPT_FILES}

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
