# Irssi/wmii Notification Script

The purpose of this script is to allow Irssi to communicate important events to
the wmii status bar. This includes private messages, and messages in public
channels that mention certain keywords (such as the user's nickname). The notification are cleared either by
issuing the /wclear command, or by switching to the window that the
notification originated from. 

#Usage

* /wclear [ nick | channel ] - This command clears the notification of the current window, or from the nick/channel specified as an optional parameter.

#Installation

* Copy the script into ~/.irssi/scripts. To have it start on irssi startup,
  symlink from ~/.irssi/scripts/autorun.
