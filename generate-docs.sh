#! /bin/sh

appledoc 	-o Documentation/appledoc \
		--project-name "AKA Beacon" \
		--project-version "0.1.0-pre" \
		--project-company "Michael Utech & AKA Sarl" \
		--company-id "com.aka-labs" \
		--create-html \
		--no-create-docset \
		--no-install-docset \
		--no-publish-docset \
		--clean-output \
		--keep-undocumented-objects \
		--keep-undocumented-members \
		--search-undocumented-doc \
		--preprocess-headerdoc \
		--print-information-block-titles \
		--merge-categories \
		--merge-category-comment \
		--keep-merged-sections \
		--prefix-merged-sections \
		--explicit-crossref \
		--use-code-order \
		--warn-missing-output-path \
		--warn-missing-company-id \
		--warn-unknown-directive \
		--warn-invalid-crossref \
		--warn-unsupported-typedef-enum \
		--ignore .m \
		--ignore _Internal.h \
		AKABeacon/AKABeacon/Classes 
