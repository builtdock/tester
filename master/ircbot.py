from collections import defaultdict
import random
import re
import os

from buildbot import config
from buildbot import interfaces
from buildbot.interfaces import IStatusReceiver
from buildbot.status import base, words
from twisted.application import internet
from zope.interface import implements


# twisted.internet.ssl requires PyOpenSSL, so be resilient if it's missing
try:
    from twisted.internet import ssl
    have_ssl = True
except ImportError:
    have_ssl = False

markov = defaultdict(list)


class C2IrcStatusBot(words.IrcStatusBot):

    """
    An IRC bot that allows control of the buildbot system and says silly
    things.
    """

    CHAIN_LENGTH = 2
    MAX_WORDS = 20000

    def privmsg(self, user, channel, message):
        """Allow buildbot's IRC logic a first crack at any private message,
        then hand it off for markov brain processing.
        """
        user = user.split('!', 1)[0]  # rest is ~user@hostname
        # channel is '#twisted' or 'buildbot' (for private messages)
        if channel == self.nickname:
            # private message
            contact = self.getContact(user)
            contact.handleMessage(message, user)
            return
        # else it's a broadcast message, maybe for us, maybe not. 'channel'
        # is '#twisted' or the like.
        contact = self.getContact(channel)
        if message.startswith("%s:" % self.nickname) or message.startswith("%s," % self.nickname):
            message = message[len("%s:" % self.nickname):]
            contact.handleMessage(message, user)
        # Markov bot processing here
        if self.nickname in message:
            message = re.compile(self.nickname + "[:,]* ?", re.I).sub('', message)
            prefix = "%s: " % (user.split('!', 1)[0], )
        else:
            prefix = ''
        buildbot_commands = [
            'commands', 'dance', 'destroy', 'force', 'hello', 'help', 'last', 'list', 'mute',
            'notify', 'source', 'status', 'stop', 'unmute', 'version', 'watch',
        ]
        if any(message.startswith(cmd) for cmd in buildbot_commands):
            # Don't add buildbot commands to the brain
            return
        add_to_brain(message, self.CHAIN_LENGTH)
        if prefix:
            sentence = generate_sentence(
                message, self.CHAIN_LENGTH, self.MAX_WORDS)
            if sentence:
                self.msg(channel, prefix + sentence)


class C2IrcStatusFactory(words.IrcStatusFactory):

    protocol = C2IrcStatusBot


class IRC(base.StatusReceiverMultiService):
    implements(IStatusReceiver)

    in_test_harness = False

    compare_attrs = ["host", "port", "nick", "password",
                     "channels", "pm_to_nicks", "allowForce", "useSSL",
                     "useRevisions", "categories", "useColors",
                     "lostDelay", "failedDelay", "allowShutdown"]

    def __init__(self, host, nick, channels, pm_to_nicks=[], port=6667,
                 allowForce=False, categories=None, password=None, notify_events={},
                 noticeOnChannel=False, showBlameList=True, useRevisions=False,
                 useSSL=False, lostDelay=None, failedDelay=None, useColors=True,
                 allowShutdown=False):
        base.StatusReceiverMultiService.__init__(self)

        if allowForce not in (True, False):
            config.error("allowForce must be boolean, not %r" % (allowForce,))
        if allowShutdown not in (True, False):
            config.error("allowShutdown must be boolean, not %r" % (allowShutdown,))

        # need to stash these so we can detect changes later
        self.host = host
        self.port = port
        self.nick = nick
        self.channels = channels
        self.pm_to_nicks = pm_to_nicks
        self.password = password
        self.allowForce = allowForce
        self.useRevisions = useRevisions
        self.categories = categories
        self.notify_events = notify_events
        self.allowShutdown = allowShutdown

        self.f = C2IrcStatusFactory(self.nick, self.password,
                                    self.channels, self.pm_to_nicks,
                                    self.categories, self.notify_events,
                                    noticeOnChannel=noticeOnChannel,
                                    useRevisions=useRevisions,
                                    showBlameList=showBlameList,
                                    lostDelay=lostDelay,
                                    failedDelay=failedDelay,
                                    useColors=useColors,
                                    allowShutdown=allowShutdown)

        if useSSL:
            # SSL client needs a ClientContextFactory for some SSL mumbo-jumbo
            if not have_ssl:
                raise RuntimeError("useSSL requires PyOpenSSL")
            cf = ssl.ClientContextFactory()
            c = internet.SSLClient(self.host, self.port, self.f, cf)
        else:
            c = internet.TCPClient(self.host, self.port, self.f)

        c.setServiceParent(self)

    def setServiceParent(self, parent):
        base.StatusReceiverMultiService.setServiceParent(self, parent)
        self.f.status = parent
        if self.allowForce:
            self.f.control = interfaces.IControl(self.master)

    def stopService(self):
        # make sure the factory will stop reconnecting
        self.f.shutdown()
        return base.StatusReceiverMultiService.stopService(self)


STOP_WORD = "\n"
TRAINING_TEXT = os.path.join(os.path.dirname(__file__), 'training.txt')


def add_to_brain(msg, chain_length, write_to_file=False):
    global markov
    if write_to_file:
        f = open(TRAINING_TEXT, 'a')
        f.write(msg + '\n')
        f.close()
    buf = [STOP_WORD] * chain_length
    for word in msg.split():
        markov[tuple(buf)].append(word)
        del buf[0]
        buf.append(word)
    markov[tuple(buf)].append(STOP_WORD)


def generate_sentence(msg, chain_length, max_words=10000):
    global markov
    buf = msg.split()[:chain_length]
    if len(msg.split()) > chain_length:
        message = buf[:]
    else:
        message = []
        for i in xrange(chain_length):
            message.append(random.choice(markov[random.choice(markov.keys())]))
    for i in xrange(max_words):
        try:
            next_word = random.choice(markov[tuple(buf)])
        except IndexError:
            continue
        if next_word == STOP_WORD:
            break
        message.append(next_word)
        del buf[0]
        buf.append(next_word)
    return ' '.join(message)


if os.path.exists(TRAINING_TEXT):
    with open(TRAINING_TEXT, 'r') as f:
        for line in f:
            add_to_brain(line, C2IrcStatusBot.CHAIN_LENGTH)
