for var in *.txt; do mv "$var" "${var%.txt}.fastq"; done

#unifed the file extention
for var in *.txt; do mv "'$var'" "'${var%.txt}.fastq'"; done

#unifed the lower/upper case of filenames
rename 'y/a-z/A-Z/' *
