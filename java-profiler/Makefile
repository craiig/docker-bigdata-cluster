all: ./honest-profiler/target/honest-profiler.zip

./honest-profiler/target/honest-profiler.zip: ./honest-profiler
	cd ./honest-profiler && mvn clean package -DskipTests

./honest-profiler:
	git clone https://github.com/RichardWarburton/honest-profiler
