# GuardianNewsApp

Dependencies managed by SPM so should just be able to download and run once dependencies resolved.

Couple of small notes:
- I put test files in the same folder as source files to make it easier to navigate. This doesn't align with Swift Packages but I thought it'd be useful if you're primarily reviewing test vs code structure.
- I re-used some of my other code for fetching the images, but ran of time to fully test that. 
- I also need to inject a factory function to the list view so I can mock the `ImageLoader`'s. 
