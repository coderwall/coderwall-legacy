# Getting Started on Windows

I wrote this guide after having trouble getting Coderwall to work on my computer. If you're a beginner to this and want to help build, this guide is for you!

## First Steps

To run Coderwall on Windows you'll need to download and install three programs on your computer. Make sure to have administrator privileges. I believe that your computer should also be 64-bit, not 32-bit. [Here's a guide on how to find out.](http://windows.microsoft.com/en-ca/windows/32-bit-and-64-bit-windows)

###[Git](http://git-scm.com/downloads)
You need Git to be able to clone the Coderwall repository on GitHub. On the installer, make sure to select the option that allows you to use Git in the Windows Command Prompt.

###[VirtualBox](https://www.virtualbox.org/wiki/Downloads)
Vagrant needs VirtualBox to create its virtual environment. You might not be able to run VirtualBox if your processor doesn't support virtualization. If you think it does, and later on it doesn't work, your computer BIOS might have disabled the feature. Check out the [Troubleshooting section below.](https://github.com/assemblymade/coderwall/docs/getting_started_on_windows.md#troubleshooting)

###[Vagrant](http://vagrantup.com)
You need Vagrant to be able to create the development environment.

Once you've got all that done, restart your computer!

## Part Two

###Clone the Coderwall repo
Start the Command Prompt. Type the following in and press enter

   depending on your choice of protocols : _(this will take a while to run so you may want to grab some coffee)_
    git clone https://github.com/assemblymade/coderwall.git coderwall
    git clone git@github.com:assemblymade/coderwall.git coderwall

Next type in

    cd Coderwall

### Start Vagrant

This is a simple command. Ready? Enter in

    vagrant up

Vagrant should now connect and begin to download the box needed to set things up. This will take a bit of time, but only needs to be downloaded once. If you're getting an error message, I've put some troubleshooting stuff below.

When you're done, you have a virtual machine box open, and you should be able to access [http://localhost:3000](http://localhost:3000)


## Troubleshooting

If Vagrant says that it can't find the `VBoxManage` binary, you will need to set up the path for VirtualBox. Go to Control Panel and find the "System Environment Variables" setting. Then add

    c:\Program Files\Oracle\VirtualBox

to your PATH variable. Make sure to add a semicolon if there are other files listed there already. [There's a good guide on how to set it here.](http://www.computerhope.com/issues/ch000549.htm)

If VirtualBox isn't starting up the virtual machine, you might need to edit the BIOS. Entering BIOS is different for each computer manufacturer, so you will need to search that up. After you're able to get into BIOS, the setting to enable 'Virtualization Technology' should be under the 'Security' tab.

If you're getting a timeout error, where your computer is unable to connect to the virtual machine, I haven't been able to find a solution to that yet :(
