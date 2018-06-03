---
- hosts: all
  tasks:

  - name: Install Administrator PGP keys
    block:
      - name: create temporary build directory
        tempfile:
          state: directory
          register: gnupghome
      - name: Import administrator PGP keys from keyserver
        shell: |
          GNUPGHOME={{ gnupghome.path }} \
          gpg \
            -q \
            --batch \
            --keyserver pool.sks-keyservers.net \
            --recv-keys {{ item }};
        args:
          executable: /bin/bash
        with_items:
          - 0x954A3772D62EF90E4B31FBC6C91A9911192C187A # daurnimator
          - 0x0A1F87C7936EB2461C6A9D9BAD9970F98EB884FD # DeviaVir
          - 0xC92FE5A3FBD58DD3EC5AA26BB10116B8193F2DBD # drGrove
          - 0xF2B7999666D83093F8D4212926CDD32189AA2885 # dpflug
          - 0xAE2D535ABD2E5B42CE1E97110527B4EFFB4A3AEB # kellerfuchs
          - 0x6B61ECD76088748C70590D55E90A401336C8AAA9 # lrvick
          - 0xA251FDF79171F98674EB2176FCC2D6E33BA86209 # ryan
      - name: Export administrator pgp keys to combined keychain file
        shell: |
          GNUPGHOME={{ gnupghome.path }} \
          gpg \
            -q \
            --batch \
            --yes \
            --export \
            --export-options export-clean,export-minimal \
            -o /var/lib/hashbang/admins.gpg
        args:
          executable: /bin/bash


  - name: Install Welcome Email
    copy:
      dest: /etc/skel/Mail/new/msg.welcome
      content: |
        From: noreply@hashbang.sh
        X-Original-To: {username}@hashbang.sh
        Delivered-To: {username}@hashbang.sh
        MIME-Version: 1.0
        From: The Local Bot <noreply@hashbang.sh>
        Date: {date}
        Subject: Press Enter to open this!
        To: {username} <{username}@hashbang.sh>
        Content-Type: text/plain

        Hey! Welcome to #!

        Hashbang (The name of the #! symbol) is a community-run online "hackerspace" based off of the core principle of "Teach. Learn. Make things do." We are a community dedicated to helping, teaching, and providing people with resources for educational and productive services. With this in mind, Hashbang (while being called an online hackerspace) does not support nor does it encourage the engagement of illegal or otherwise disruptive activities that may have a negative impact on the resources of other users.

        The name of hashbang is based off of the symbol '#!', found at the start of a shell script. This symbol instructs the operating system what program is required to "do" something with the code. Hashbang runs the same way. We try to instruct our users on the tools and skills required to -do- whatever they want for themselves. Likewise if you want something done, -do- it yourself. Don't know how? Ask. We're here to help new people get used to a Linux/Unix environment and to start them off with making software, learning how the terminal and services work... or perhaps helping talk through a challenging work problem someone faces at a major tech company. We welcome all skill levels and backgrounds.

        Software is almost never complete, and there might always be something off. Being a community-run service, hashbang encourages users to find bugs within the software and attempt to fix them. Most of our repositories are stored online on GitHub (https://github.com/hashbang) and are easily accessible. If you have any questions about any of our offerings, or just want to chat, you can switch to the first window (ctrl-B then 1) and talk to a number of other users in real time.

        Thank you for taking the time to read this welcome message, and welcome to #!

        To find out more try 'man hashbang' on one of the terminal tabs [ <Ctrl-b> c ]

        Currently, the ~/Public folder isn't exposed over HTTP by default;
        however, users can use the `SimpleHTTPServer.service` systemd unit file (in `~/.config/systemd/user`, modify it to set port) or a `@reboot` crontab entry to run `python3 -m http.server <port>` to provide a webserver exposing it.

        This message will self-destruct in 10 seconds.


  - name: Install Welcome Message
    block:
    - name: Install welcome template script
      copy:
        dest: /etc/hashbang/welcome
        content: |
          #!/bin/sh

          cat /etc/hashbang/welcome.pre

          if [ -n "$TMUX" ]; then
          	sed "s/\\\$USER/${USER}/" /etc/hashbang/welcome.tmux
          else
          	sed "s/\\\$USER/${USER}/" /etc/hashbang/welcome.notmux
          fi

          cat /etc/hashbang/welcome.post

    - name: Install welcome header
      copy:
        dest: /etc/hashbang/welcome.pre
        content: |
             _  _    __
           _| || |_ |  |  Welcome to #!. This network has three rules:
          |_  __  _||  |
           _| || |_ |  |  1. When people need help, teach. Don't do it for them
          |_  __  _||__|  2. Don't use our resources for closed source projects
            |_||_|  (__)  3. Be excellent to each other

    - name: Install welcome body for non-tmux users
      copy:
        dest: /etc/hashbang/welcome.notmux
        content: |
           Things to explore:

             * You can start 'tmux' to enter a tmux session.
               Help will be displayed when tmux is started.

             * You can resume a detached tmux session at any time.
               Use 'tmux attach' to resume your tmux session.

             * Your Hashbang email address is $USER@hashbang.sh
               The `mutt` email client is preconfigured for you.

    - name: Install welcome body for tmux users
      copy:
        dest: /etc/hashbang/welcome.notmux
        content: |
           Things to explore:

             * You are in a 'tmux' session. There are three tabs below.
               Navigate with <Ctrl-b> + a tab number.

             * You are already in our IRC channel in "tab 1"
               Type <Ctrl-B> + 1 to reach it and chat with us.

             * Your Hashbang email address is: $USER@hashbang.sh
               Type <Ctrl-B> + 2 to check your emails in mutt

             * You can detach from this tmux session with <Ctrl-b> + <d>
               You can also re-attach outside of tmux with 'tmux attach'

    - name: Install welcome footer
      copy:
        dest: /etc/hashbang/welcome.post
        content: |
             * To learn more about us and our offerings type: man hashbang

           Like what we're doing? Consider donating to expand our efforts.
             * Bitcoin       - [ 1DtTvCLiUMhs21QcETQzLyiqxoopUjqBSU ]
             * Google Wallet - [ donate@hashbang.sh ]
             * PayPal        - [ http://goo.gl/aSQWy0 ]

           Community shell servers generously sponsored by: (http://atlantic.net)


  - name: Install man page
    copy:
      dest: /etc/man/man7/hashbang.7
      content: |
        .\"   Man page for hashbang
        .TH man 7 "29 May 2014" "0.5" "#! man page"

        .SH NAME
        #! \- "shell" service and collective of awesome people.

        .SH SYNOPSIS

        bash <(curl hashbang.sh)

        .SH DESCRIPTION

        We are a diverse community of people who love teaching and learning.
        Putting a #! at the beginning of a "script" style program tells a computer that
        it needs to "do something" or "execute" the file. Likewise, we are a community
        of people that like to "do stuff".

        If you like technology and want to learn to write your first program, learn to
        use Linux, or even take on interesting challenges with some of the best in
        the industry, you are in the right place.
        .SH EXAMPLES
        .TP

        .BI ssh\ someuser@hashbang.sh
        Use the "ssh" command to get yourself back into your account from any computer
        that has your private key.
        .TP
        .BI cat\ foo
        echo the foo file to the console

        .SH AVAILABLE SOFTWARE
        .SS Account Management
        hashbangctl - An account management program which can update your ssh keys, account name, and default shell.
        .SS Compilers / Interpreters / Programming Languages
        perl - A high-level, general-purpose dynamic programming language. Commonly
        referred to as "the duct tape of the internet."

        python - A high-level, general-purpose programming language that emphasizes
        code readability.

        ruby - A dynamic, object-oriented general-purpose programming language.

        haskell [ghc] - A standardized, general-purpose programming language with non-strict
        semantics and strong static typing.

        lua - A lightweight multi-paradigm programming language designed as a scripting
        language.

        clojure - A general-purpose programming language with an emphasis on functional
        programming. It is a dialect of the Lisp programming language.

        go - A statically-typed language developed at Google with syntax loosely derived from C with
        garbage collection.

        nodejs - A cross-platform runtime environment for server-side and network
        applications written in javascript.

        sbcl - (Steel Bank Common Lisp) A Lisp implementation that features a high
        performance native compiler, Unicode support, and threading.

        ghc - (The Glorious Glasgow Haskell Compilation System) a native code compiler
        for Haskell.

        gcc - (GNU Compiler Collection) A compiler system that supports C, C++ and
        various other programming languages.

        smlnj -(Standard ML of New Jersey) a compiler and programming environment for
        Standard ML
        .SS Text Editors
        vim - A popular vi clone and the IDE of choice of most of the #! regulars.
        Ships by default on all operating systems that matter.

        emacs - A very capable scriptable text editor also capable of being a full IDE
        with all the power of vim implemented in different ways. Not in as wide of
        use as it once was but plenty of skilled hackers still swear by it.

        nano - A text editor that emulates the Pico text editor and is part of the GNU
        Project.

        joe - (Joe's Own Editor) a text editor designed for ease of use.

        pico - (Pine Composer) a text editor originally integrated with the pine e-mail
        client and designed at the Office of Computing and Communications at the
        University of Washington.

        mcedit - Internal text editor for the Midnight Commander file manager.

        zile - An Emacs like text editor that is less resource intensive.
        .SS Password Management
        pass - A shell based password manager.
        .SS Cryptography / Hashing
        encfs - A FUSE-based cryptographic filesystem that transparently encrypts files
        using an arbitrary directory as storage for the encrypted files.

        gpg - (GNU Privacy Guard) A GPL Licensed alternative to the PGP suite of
        cryptographic software compliant with RFC 4880.

        md5sum - Calculates and verifies 128-bit MD5 hashes as described in RFC 1321.

        shasum - Calculates and verifies SHA hashes.

        bcrypt - A key derivation function for passwords based on the Blowfish cipher.
        .SS Time Management
        calendar - Checks current directory or CALENDAR_DIR environment variable for a
        file named calendar and displays appointments and reminders.

        remind - A sophisticated reminder service.

        wyrd - A text-based front-end to the Remind program.

        tudu - A command-line tool to manage TODO lists hierarchically.
        .SS Shells
        bash - (Bourne Again Shell) The standard shell on most Linux and unix-like
        systems which is a GNU replacement for the Unix Bourne shell. A linux classic
        brah.

        zsh - (Z Shell) An extension of the Bourne shell extended with features from
        ksh and tcsh.

        fish - (Friendly Interactive Shell) An attempt to make a more interactive,
        user-friendly shell.

        ksh - (Korn Shell) A shell backwards compatible with the Bourne shell but also
        includes many features of the C shell.
        .SS Email
        mutt - A text-based email client. "All mail clients suck. This one just sucks
        less."
        .SS Math
        units - Unit conversion utility.

        dc - A reverse-polish desk calculator which supports arbitrary-precision
        arithmetic.

        qalc - A small simple to use command-line calculator.

        bc - An arbitrary precision calculator language

        .SS Chat / IM
        weechat-curses - Wee Enhanced Environment for Chat (Curses version)

        irssi - A text-based IRC client written in the C programming language.

        finch - A console-based instant messaging client based on the libpurple
        library.

        bitlbee - Bitlbee brings Instant Messaging to IRC clients. It has support for
        multiple IM networks/protocols including Google Talk.

        .RS
        To use bitlbee in weechat enter
        .RS
        .B
        /server add bitlbee irc.hashbang.sh/6610
        .RE
        then
        .RS
        .B
        /connect bitlbee
        .RE
        this will force join you into the
        .B
        &bitlbee
        channel. If you are interested in using Google Talk follow this guide
        http://wiki.bitlbee.org/HowtoGtalk
        .RE

        .SS Web Browsing
        elinks - Similar to links, but also supports Form Input, Password Management,
        and Tabbed Browsing

        lynx - A general purpose distributed information web browser.

        w3m - A text based web browser and pager.

        html2text - Reads an HTML document and outputs plain text characters.
        .SS Database
        redis [redis-*] - A networked, in-memory, key-value data store with optional durability
        written in ANSI C.
        .SS File Management
        mc - (Midnight Commander) A text-based file manager similar to Norton
        Commander.

        scp - (Secure Copy) A client that uses the Secure Shell protocol to securely
        transfer files between hosts. 

        rsync - A file synchronization and file transfer program that minimizes network
        data transfer by using a form of delta encoding called the rsync algorithm.

        duplicity - A software suite that provides encrypted, digitally signed,
        versioned, remote backups of files.

        ranger - A text-based file manager written in Python.

        du - (disc usage) Estimates file space usage on a filesystem.

        ncdu - A simple ncurses disk usage analyzer.

        stow - A symlink manager. Helpful for managing several locally-installed things.

        find - Used to search the filesystem for a particular file.

        locate - Searches a prebuilt database for files on a filesystem.

        tree - A recursive directory listing program that produces a depth-indented
        listing of files.
        .SS Archiving
        atool - A script for managing file archives of various types.

        zip - A PKZIP compatible compression and file packaging utility.

        unzip - Utility for uncompressing PKZIP compressed files.

        p7zip - A program for compressing and uncompressing 7-zip compressed files.

        tar - Utility used for compressing and uncompressing tar files.

        gzip - An application used to create gzip compressed files.

        zpaq - A program for creating journaling or append-only compression files.
        .SS Network
        iperf - A bandwidth measurement utility.

        nmap - (Network Mapper) A security scanner used to discover hosts and services
        on a computer network.

        mtr - (Matt's TraceRoute) Combines the functionality of the traceroute and ping
        programs in a single network diagnostic tool.

        telnet - Used to communicate with another host using the telnet protocol.

        ssh - A client used to connect to a host using the Secure Shell protocol.

        siege - A multi-threaded http load testing and benchmarking utility.

        lftp - A file transfer program that allows sophisticated ftp, http and other
        connections to other hosts.

        curl - A tool used to transfer data from or to a server using HTTP, HTTPS, FTP,
        FTPS, SCP, SFTP, TFTP, DICT, TELNET, LDAP or FILE).

        aria2 [aria2c] - A utility for downloading files via HTTP(S), FTP, BitTorrent, and
        Metalink.

        ipcalc - A program that calculates IP information for a host.

        socat - (SOcket CAT) A command line based utility that establishes two
        bidirectional byte streams and transfers data between them.

        netcat - A networking utility which reads and writes data across networks from
        the command line.

        ssh-copy-id - A script that uses SSH to copy a public key to a remote machine's
        authorized_keys.
        .SS Image Tools
        imagemagick [convert, mogrify, ...] - A software suits used to create, edit, and compose bitmap images.

        .SS Code Management
        cvs - (Concurrent Versions System) A revision control system using
        client-server architecture.

        svn - (Subversion) A software versioning and revision control system
        maintained by apache and designed as a successor to CVS

        mercurial [hg] - A distributed revision control system designed for high
        performance, scalability, and decentralization.

        git - A distributed version control system with an emphasis on speed, data
        integrity, and support for distributed, non-linear workflows.

        tig - A text-mode interface for git.

        cloc - Counts and computes differences of lines of source code and comments.

        diff - Compares files line by line.

        vimdiff - Edits 2 - 4 versions of a file with vim while showing differences.

        ctags - A programming tool that generates an index file of names found in
        source and header files of various programming languages.

        cmake - Software for managing the build process of software using a
        compiler-independent method.

        shellcheck - Linter for shell scripts
        .SS Games/Toys

        zangband - A dungeon-crawling roguelike game derived from Angband and based on
        Roger Zelazny's The Chronicles of Amber.

        nethack - A roguelike game descended from the game Hack and Rogue.

        slashem - (Super Lotsa Added Stuff Hack - Extended Magic) is a variant of the
        roguelike game NetHack that offers extra features, monsters, and items.

        frotz - An interpreter for Infocom games and other z-machine games.

        bsdgames [adventure, ...] - A collection of text games from BSD systems.

        bastet - (Bastard Tetris) A Tetris clone.

        gnugo - Open source implementation of the game Go.

        gnuchess - Chess
        .SS System Management Utilities
        htop - An interactive system-monitor process-viewer.

        strace - Application for tracing system calls and signals.

        cgroups - (Control Groups) A kernel feature to limit, account, and isolate
        resource usage of process groups.

        command-not-found - (Debian) Suggest a package when the user calls a command
        that could not be found.

        .SS Window/Session Managers

        tmux - An Application used to multiplex several virtual consoles, allowing a
        user to access multiple separate terminal sessions inside a single terminal.

        screen - Application used to multiplex several virtual consoles, allowing a
        user to access multiple separate terminal sessions in a single terminal.

        byobu - An enhancement for the terminal multiplexers Screen or Tmux that can be
        used to provide on screen notification or status as well as tabbed multi-window
        management.
        .SS Misc. / Unsorted (Sort these!)
        pv - Monitors the progress of data through a pipe.

        tsung - Used to stress test HTTP, WebDAV, LDAP, MySQL, PostgreSQL, SOAP, and
        XMPP servers.

        xargs - Used to build and execute command lines from standard input.

        parallel - Shell tool for executing jobs in parallel using one or more
        computers.

        ag - A significantly faster replacement to ACK with a built in VCS.

        watch - Executes a program periodically, showing the output fullscreen.

        libev - A high-performance event loop for C.

        libevent - Provides a mechanism to execute a callback function when a specific
        event occurs on a file descriptor or after a timeout has been reached.

        cowsay - Generates ASCII pictures of a cow with a message.

        dos2unix - Converts line breaks in a text file from DOS format to Unix format.

        unix2dos - Converts line breaks in a text file from Unix format to DOS format.
        .SH HISTORY
        2004 - lrvick secured free-for-all usage of a dedicated server, hosted at
        "The Planet" datacenter in Austin, TX, in exchange for providing free system
        administration services to an educational web application provider. He
        distributed shell accounts to a group of friends for personal projects,
        organizing resources and efforts via IRC.

        2006 - Having outgrown the shared server, the community opted to invest in our
        own dedicated server, lovingly named "Adam". All projects were migrated over,
        and a few months later "Eve" was added for redundancy and to minimize downtime.
        These were hosted at SiteGenie in Rochester, MN.

        2008 - As a hosting service, we hosted many web projects visited by hundreds of
        thousands of users, in addition to seeing hundreds of users on our IRC and
        shell services. Our community was known in multiple IRC circles to have very
        well-developed overall system security, and we regularly dealt with various
        types of attacks trying to break through. A "Script Kiddie" named Piratox,
        unable to break in through any usual methods, opted to make use of a large
        botnet, disrupting us with a large scale DDOS attack.

        The attack was significant enough that the entire SiteGenie datacenter was
        taken offline. Though we tracked down Piratox and ended the dispute, SiteGenie
        was unprepared to deal with the possibility of further DDOS attacks of similar
        scale and promptly ended our contract. They generously offered to overnight our
        hard drives to any location we chose. Seeing the potential in this, we involved
        it in the backup plans that had already been set in motion.

        Echelon, a volunteer admin, brought "Noah" online in his Ohio basement.
        Bluescales, another volunteer admin, rushed to setup a VPS in a Montana
        Datacenter. He dubbed it "Moses". We quickly routed essential services from
        backups between the two servers while one of the two backup drives containing
        user files was overnighted to Noah. Shell user files were available to our
        community again within 24 hours.

        With emergency options in place, we sought a new primary server. After
        reviewing our budget and options, we opted for a dedicated server at a newer
        company, VolumeDrive, in Wilkes Barre, Pennsylvania. We took a chance on them
        due to their reputation for inexpensive, unmetered bandwidth plans with
        regular bandwidth testing. "Melchiz" was born, and quickly became responsible
        for community services including shells, email, and IRC, as well as hosting
        most smaller websites.

        VolumeDrive was a good fit for most of our services; however, like SiteGenie,
        they were unwilling to deal with the unwanted attention that our historical
        reputation could bring. To address this, we deployed "Samson" in an undisclosed
        location, ensuring it would be difficult to target by disruptive parties.
        "Gideon" was deployed in Germany as a dumb proxy to more reliably protect
        Samson's location. Were it to ever go down, more could rapidly take its place.
        We felt really good about the maintainability of this setup.

        2010 - Samson needed a kernel update to address security issues that had
        recently come to light. One of our volunteer admins, Viaken, decided to take on
        the kernel update on his own, but did not include the correct SATA driver. On
        reboot, Samson experienced a kernel panic. Per a special agreement with the
        datacenter, hosting was available and free so long as support was never
        contacted. Thus, Samson was to remain frozen at a kernel panic screen, and
        may still be hung there to this day. Gideon, now purposeless, was taken
        offline shortly thereafter.

        We were left with no choice but to risk hosting all services on Melchiz until
        a better solution could be secured.

        2013 - After frequent downtime and multiple disputes with VolumeDrive
        (including a case where they mistakenly formatted one of our production hard
        drives), our community sought to "go big or go home". We went big and secured
        the dedicated server "Og". Og's specs were more than overkill for everything
        we provided, but we knew it would be worth it for our long-term goals of
        expanding our free community offerings to the general public.

        2014 - #! shells are now available to the general public. Welcome!


        .SH You can help!

        Fork, make changes, and submit Github Pull Requests here:

        https://github.com/hashbang/shell-etc

        This man file can be updated here:

        https://github.com/hashbang/shell-etc/blob/master/man/man7/hashbang.7

