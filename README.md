# wiswa
what if surfing was automated?, abbreviated 'wiswa' is a simple shell script for surfing the web.

the internet archive is a treasure trove of content, new and old, all interesting. wiswa is a way to automatically sift through it and send some (hopefully)
interesting bits to you. it fetches images, video, and audio from the internet archive by searching for a term, taking the first few results, and for each one
sending a file from it to a discord webhook, then repeating with a random word from the description.

to set it up in your server, simply clone the script, locally or on some hosting service like replit. set the GENESIS environment variable to the startign term,
and WEBHOK_URL to your discord webhook url. it might take a few tries for the term to 'catch' and being decent recursing; be patient.
