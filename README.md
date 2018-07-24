# offloading-client-iOS
Offloading enabled iOS application


Requirements

BTE framework requires iOS 11.0+, although iOS 11.4.1 support hasn't been tested in a while.


Installation

* BTE framework comes attached with the testing application
* Just drag BTE.framework into your project. Method calls support is given in the below list.


Methods

* To access Image Recognition, call method ‘recognizeImage()’ in the respective view controller attached to access device camera 
* To initiate recognizing images, call the method start() and to complete the task simply call method finish() which will finish the execution and exit
* Let the code pain to be handled by the framework. All necessary decision will be provoked by the application by accessing the device parameters. The decision will help to execute Image Recognition task to be in the local device itself or in the remote
* BTE framework do the needful on behalf of the developer 
* Work less and do more!!

Please use the issues tab for further inquiry, hope to provide the best solution at earliest. 


MIT License

Copyright (c) 2018 Girijah Nagarajah

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
