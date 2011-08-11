**Generate your own API Reference**
===========

###_Use cases_
1. **Most likely:** You tweaked some class members or even added some new classes. You want those to show up in Xcode's quick help.
2. _Less likely:_ You want to re-generate the HTML version of the documentation to host on a server
3. _Not likely:_ You want to re-generate the Atom feed (this is the file Xcode uses to track the official documentation).

###_Requirements_

You're gonna need to install `appledoc`, a command-line tool:

 - **Grab it:** [The official site](http://www.gentlebytes.com/home/appledocapp/).
 - **Compile it:** Open in Xcode and build.
 - **Install it:** Copy the `appledoc` binary to `/usr/local/bin` or any other directory in your `$PATH`.

##The easy way

Just run the small application 'GenerateDocs' within this folder. Choose the output option that fits your needs. All of the output is created in the 'output' directory.

##The advanced way

If you're the kind of person who loves to know how everything works… well, read on :).

`GenerateDocs.app` is a simple apple script that invokes the appledoc tool with the right settings. All of the settings files are located in the (hidden) `.support/` folder.