This script right now downloads lectures from coursera. This will work both for published lectures as well as lectures in preview mode.
I will add ability to download materials if need be.

    ruby coursera-dl.rb <username> <password> <course-name>

If the course is in preview add true as the last parameter:
    ruby coursera-dl.rb <username> <password> <course-name> true


Thanks to https://github.com/abrausch/coursera-downloader for inspiration and a great starting point.