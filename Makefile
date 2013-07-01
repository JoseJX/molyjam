RELEASE_NAME=test

LUA_FILES=main.lua ground.lua plane.lua conf.lua cabinview.lua caller.lua
DATA_FILES=plane.png cloud1.png bear.png cabin.png

FILELIST=${LUA_FILES} ${DATA_FILES}

all: love 

love:
	zip -9 -q -r ${RELEASE_NAME}.love ${FILELIST}		
	

test:
	love .

vtest:
	vglrun love .

clean:
	rm -f ${RELEASE_NAME}.love	
