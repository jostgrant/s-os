# The Design Of S-OS

For better-or-worse, ArchLinux is one of the most 'sane' ways to build an opinionated Linux distribution in 202X.
There's many quibbles, to outright concerns I have for "system stablity" by default -- but most of which can practically be "resolved" with a clever enough partitioning scheme.

What I've come up with in-practice, is a spin on the A/B Root layout. (See Android OTA / "Seamless Updates" and even more contemporarily VanillaOS to get a loose idea of how this works.)

Our assertion is "harddrive space is cheap" and the OS is not an issue we really want to solve anways; We just want something stable enough there's always recourse if something "goes wrong".
So we are making certain assumptions about the base-sytem we are installing on; We expect a half terabyte drive of free-space on the disk you want to install S-OS on. (Nearly 286gb is the system itself).

This is the FS layout as-of Feb 2025:

```
4.4G  /boot
8.8G  /boot/recv
16G   swap
64G   /dev/mapper/verA-root
64G   /dev/mapper/verB-root
128G  /dev/mapper/rest-syst
100%FREE /dev/mapper/home-base
```

---

Note: Rest-Syst as an (soon to be) optional directory that is taking restic snapshots so you can pin versions to make it easy to rollback from.
It's not manadatory but highly reccomended and will allow more than just A/B root (ie: two versions to roll from).


We have a self-imposed limit right now of 64gb for the A/B partions.
64gb is pretty tight, but we want most of the software you interact with day-to-day be in the home partition via pet-containers and a lisp image;
So it's really not that bad. With anything and everything I can think of right-now in the main-image itself, including nvidia drivers and cuda
we're still under 50% full and we're basically half that without nvidia.
