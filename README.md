# Intro

This is a collection of repos and scripts designed to be able to easily boot up a set of services for docker containers. This is light on documentation for now as things stababilize. The best way to understand what's going on is to read the Makefiles/Dockerfiles in each directory.

If you want a quick start, try running make all and watch it start hadoop and spark containers for you.

There are a number of other containers that work, such as accumulo, tachyon, and zookeeper. These haven't been incorporated into benchmarks yet.

# TODO & Caveats

The first thing to know about the internals is that hadoop configurations are shared via docker volumes. This limits you to using one host for now, or propagating a valid hadoop configuration to the other contaiiners. We need to find a nice way of pushing hadoop configurations between different hosts easily.

# Useful Links for development

 * Reducing spark build times: https://cwiki.apache.org/confluence/display/SPARK/Useful+Developer+Tools

# Potential improvements

 * Use docker orchestration to provide a cluster interface - https://blog.docker.com/2016/06/docker-1-12-built-in-orchestration/
