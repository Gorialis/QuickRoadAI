============
QuickRoadAI
============

QuickRoadAI is an OpenTTD AI that tries to build intra-city road infrastructure, fast.

Installing
-----------

Squirrel is interpreted and does not require compilation.

To package:

1. Update the date and version in `QuickRoadAI/info.nut <QuickRoadAI/info.nut>`__

2. Create a tar file containing the contents of `QuickRoadAI <QuickRoadAI>`__, the README and LICENSE.

3. Rename the tar file to ``QuickRoadAI-<version>.tar``, where ``<version>`` is the version number (e.g. ``QuickRoadAI-6.tar``)

To use the package in OpenTTD:

1. Place the ``.tar`` file into the ``ai`` directory of the OpenTTD user "personal" folder.

   - On Windows 2000/XP, this will be in ``C:\Documents and Settings\<username>\My Documents\OpenTTD\ai``

   - On Windows Vista/7/8.1/10, this will be in ``C:\Users\<username>\Documents\OpenTTD\ai``

   - On macOS, this will be in ``~/Documents/OpenTTD/ai``

   - On Linux, this will be in ``$XDG_DATA_HOME/openttd/ai``

2. Restart OpenTTD if it is open

Distributions are automatically packaged by `GitLab CI <https://gitlab.com/Gorialis/quickroadai/pipelines>`__ on commit, check the artifacts of the latest job if you do not want to package yourself.
