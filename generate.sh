#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

BUILD_ROOT="build"
OUTPUT_DIR="${BUILD_ROOT}/asciidoc/html5"
PDF_FILE="EOEPCA-use-case-analysis.pdf"

echo "Remove existing output directory"
find "${BUILD_ROOT}" -type f -exec rm -f {} \;

# Create output dirs and copy resources
echo "Create output directory: ${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
echo "Copy images/ to output directory"
cp -r src/docs/asciidoc/images "${OUTPUT_DIR}"
echo "Copy stylesheets/ to output directory"
cp -r src/docs/asciidoc/stylesheets "${OUTPUT_DIR}"
echo "Copy resources/docs/ to output directory"
mkdir -p "${OUTPUT_DIR}"/resources
cp -r src/docs/asciidoc/resources/docs "${OUTPUT_DIR}"/resources

# Generate HTML
echo -n "Generating HTML output: "
docker run --rm -it -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor -D "${OUTPUT_DIR}" src/docs/asciidoc/index.adoc
echo "[done]"

# Generate PDF
if [ "$1" == "nopdf" ]
then
    echo "WARNING: Skipping generation of PDF file (${PDF_FILE})"
else
    echo -n "Generating PDF output (${PDF_FILE}): "
    docker run --rm -it -v $(pwd):/documents/ asciidoctor/docker-asciidoctor bash -c "cd src/docs/asciidoc && asciidoctor-pdf -D \"../../../${OUTPUT_DIR}\" -o \"${PDF_FILE}\" index.adoc"
    echo "[done]"
fi

cd "${ORIG_DIR}"
