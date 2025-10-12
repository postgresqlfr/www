
PGDOCS_DIR=pgdocs_fr
PGDOCS_TAG?=master
PGDOCS_URL?=https://github.com/gleu/pgdocs_fr.git

##
## Convertir la doc au format markdown
##

$(PGDOCS_DIR): #: cloner le dépot de doc
	git clone --depth=1 $(PGDOCS_URL)

checkout: $(PGDOCS_DIR) #: mettre à jour le dépot de doc
	# fetch the tags
	git -C $(PGDOCS_DIR) fetch --depth=1 origin +refs/tags/*:refs/tags/*
	# switch to the tag
	git -C $(PGDOCS_DIR) checkout $(PGDOCS_TAG)

SGML2_STYLESHEET?=sgml2md/stylesheet.xsl

# Get all XML files from the postgresql directory and subdirectories
XML_FILES := $(shell find $(PGDOCS_DIR)/postgresql -name '*.xml')

# Transform the list to target .md files in src/docs (preserving directory structure)
MD_FILES := $(patsubst $(PGDOCS_DIR)/postgresql/%,src/docs/%,$(XML_FILES:.xml=.md))

# Convert all docs files
docs: $(MD_FILES)


src/docs/%.md: $(PGDOCS_DIR)/postgresql/%.xml
	@mkdir -p $(dir $@)
	-pandoc -f docbook -t markdown --standalone $^ > $@ 
#	xsltproc -stringparam profile.condition html --xinclude $(SGML2_STYLESHEET) $^ > $@

www/docs/%.md: $(PGDOCS_DIR)/postgresql/%.xml
	xsltproc $(SGML2_STYLESHEET) $^ > $@

##
## Nettoyage
##


clean:
	rm -fr $(PGDOCS_DIR)
