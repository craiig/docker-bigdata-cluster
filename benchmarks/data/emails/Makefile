all: get_emails

emails := http://csmining.org/index.php/spam-email-datasets-.html?file=tl_files/Project_Datasets/task2/CSDMC2010_SPAM.zip

# Download the dataset
CSDMC2010_SPAM.zip:
	curl $(emails) >$@

# Unzip the dataset
get_emails: CSDMC2010_SPAM.zip
	unzip -j CSDMC2010_SPAM.zip "CSDMC2010_SPAM/CSDMC2010_SPAM/*" -x "CSDMC2010_SPAM/CSDMC2010_SPAM/readme.txt" -d emails
