# The Sweet and Simple Raspberry Pi Imager

The [Raspberry Pi Foundation](https://www.raspberrypi.org/) has introduced the new Raspberry Pi Imager to help ease the creation of RPi SD card images. Here's a quick intro to their new utility

## The Imager
You can find the Raspberry Pi Imager over at the usual [Raspberry Pi Downloads](https://www.raspberrypi.org/downloads/) page.  Versions exist for Mac, Ubuntu, and Windows. I will download and demonstrate the Mac version. I imagine that the Windows installer is just as easy as Mac and I'm sure Ubuntu fans will know how the handle the DEB package (apt-get is your friend).

Installation on Mac consists of the usual DMG image that mounts to your desktop, and then a typical installer window appears:
![install](https://github.com/waverunner/articles/blob/master/media/install.png)

Simply drag the cute raspberry icon to the Application folder and you are done.  Invoke that fron Launchpad and you are presented with a series of simple buttons and menus to choose from. It really cannot be simpler than this:
![screen](https://github.com/waverunner/articles/blob/master/media/screen.png)

## Images and Options available
The default options contain a variety images for various Raspberry Pi models. Raspbian is the top choice with 2 available options for smaller "Lite" and fatter "Full" versions available. The LibreELEC Kodi entertainment system is available in various model specific builds. Ubuntu 18 & 19 have 32bit abd 64bit builds available for different Pi models. There is an RPi 4 EEPROM recovery utlity, and a function to format your card using FAT32.  Finally, a generic image insaller option is available that I will try out a little later. Pretty handy for a simple and compact utility.

## Install some images
I had a 16g micro SD card that I decided to play with. I selected the default Raspian image, chose my attached USB/SD device, and pressed WRITE. Here is a brief demo:

![demo](https://github.com/waverunner/articles/blob/master/media/demo.gif)

I didn't post the entire se uence there ... I believe it downloaded the image as it was writing and took a few minutes on my wireless connection to finish. The process goes through a write and then verify cycle before it is finished. When it was done I ejected the device, popped the card into my RPi 3, and was treated to the usual graphical Raspbain setup wizard and desktop environment. 

That wasn't quite enough for me; I get plenty of Linux on a daily basis was was looking for a little more today.  I went back to the [Raspberry Pi Downloads](https://www.raspberrypi.org/downloads/) page and pulled down the RISC OS image.  This process was nearly as easy.  Download the RISCOSPi.5.24.zip file, extract it, and find the ro524-1875M.img file. From the Operating System button I selected the "Use Custom" option and selected the desired image file.  The process was pretty much the same, the only real difference being I had to hunt around my Downloads directory and select an image.  Once the file was finished writing, back into the Pi 3, and RISC OS was ready to go.

## Gripes on USB C
This is just a silly aside, but how many of you are a bit frustrated with the total inconvenience of USB C these days? I'm using a MacBook Pro which only has USB C ports and am subject to a never ending swap of adapters to get things done.  Take a look at this:
![adapter](https://github.com/waverunner/articles/blob/master/media/adapter.png)

Yes, that is a USB C to USB A adapter, then a USB to SD card reader, and a SD to micro SD adapter inside. I probably could have found something online to simplify this, but these are the parts I had on hand to support my family's myriad Mac, Windows, and Linux hosts.  Enought about that, I hope you got a chuckle from that insanity.

## Summary
The new Raspberry Pi Imager is a simple an effective tool for getting off the ground quickly with Raspberry Pi images. BalenaEtcher is a simlar tool for imaging your removable devices, but this new Raspberry Pi Imager makes the process of common RPi OS installations (like Raspian) a bit easier by eliminating the steps to fetch those common images.