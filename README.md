# MoulinetteArcade

## Purpose of this script

This project is intended to test your Epitech Arcade project. <br/>
It takes into account projects with <b> CMakeLists.txt and Makefile </b> . <br/>

### This script allows you to test:
- The compilation of your project <br/>
- The name of your binary <br/>
- The presence of the right libraries <br/>
- Delete unwanted files <br/>
- Create a pdf and html documentation (Doxyfile only) <br/>
&#8594; Soon a debugging mode :rocket: <br/>

There is no prerequisite to run the bash script. <br/>

## Execute Script
``` ./buildProject ```
This command execute CMakeLists or Makefile. <br/>
<b> This script is to be put in the root of your Arcade project. <b/>

### Flags: :books:

```--help | -h```
<br/>
  Print usage script.

```--documentation | -d```
<br/>
  Find Doxygen file configuration and execute them to create pdf file.

```--moulinette | -m```
 <br/>
  Executes the commands of the real moulinette for compilation. <br/>
  Checks the name of the binary and the presence of the different <br/>
  libs for the games and the graphic managers. <br/>
  
```--clean | -c```
 <br/>
  Delete the binary, the libraries and the build folder if it exists. <br/>
  
```--version | v```
 <br/>
  See the version of the script.<br/>
