RELEASE_NAME=test

LUA_FILES=main.lua ground.lua
DATA_FILES=

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
