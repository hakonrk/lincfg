#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

local $/;
my $toc = '';
my $document = <>;

sub escape_meta {
    my $chunk = shift;
    $chunk =~ s/&/&amp;/g;
    $chunk =~ s/</&lt;/g;
    $chunk =~ s/>/&gt;/g;
    return $chunk;
}

$document =~ s#<url:\s*([^>]+)>\s*(.+?)</url>#<a target="_blank" href="$1">$2</a>#gs;
$document =~ s#^«(\n.+?)»#<table><tr><td><pre>$1</pre></table>#msg;
$document =~ s#«(.+?)»#<code>$1</code>#gs;
$document =~ s#^´(\n.+?)´#'<table><tr><td><pre>'.escape_meta($1).'</pre></table>'#mesg;
$document =~ s#´(.+?)´#'<code>'.escape_meta($1).'</code>'#egs;
$document =~ s#¨(.+?)¨#<var>$1</var>#g;
$document =~ s#¡(.*)#<dfn>$1</dfn>#g;
$document =~ s#\n((?:·.*\n)+)#\n<ul>\n$1</ul>\n#gm;
$document =~ s#^·\s*#<li>#gm;
make_headlines();

print <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <style type="text/css">
    body {
        background: #14171f;
        color: #a0a0a0;
    }

    a:link {
        color: #667fb8;
        text-decoration: none;
    }

    a:visited {
        color: #8873b0;
        text-decoration: none;
    }

    a:active, a:hover {
        text-decoration: underline;
    }

    a.nolink {
        text-decoration: none;
    }

    pre {
        border: 1px solid #2a334a;
        border-radius: 1ex 1ex;
        padding: 1ex 1ex 1ex 1ex;
        background: #1a1f29;
        margin: 0 0 0 0;
    }

    table {
        margin: 1ex 0 1ex 0;
    }

    kbd {
        font-style: normal;
        color: #ca2e15;
    }

    dfn {
        color: #80a0ff;
    }
  </style>
  <title>Linux-oppsett</title>
</head>
<body>
EOF

print "$toc\n$document</body></html>\n";

sub make_index {
    my ($level, $index_counter) = @_;
    my $ret = '';
    for (my $lvl = 1; $lvl <= $level; $lvl++) {
        $ret .= $index_counter->[$lvl] . '.';
    }
    return $ret;
}

sub make_headlines {
    my $level;
    my $last_level = 0;
    my $current_level = 0;
    my @index_counter;

    while ($document =~ /^(­+) (.+)/gm) {
        my $headline = $2;
        $level = length $1;
        if ($level > $last_level) {
            $index_counter[$level] = 1;
        } else {
            $index_counter[$level]++;
        }

        my $index = make_index($level, \@index_counter);
        $document =~ s#^­(.*)#<h$level><a class=nolink name="$index">$index $headline</a></h$level>#m;

        if ($level > $last_level) {
            $toc .= '<ol>' x ($level - $last_level);
        } elsif ($level < $last_level) {
            $toc .= '</ol>' x ($last_level - $level);
        }
        $toc .= qq(<li><a href="#$index">$headline</a>\n);
        $last_level = $level;
    }
    $level = 0;
    $toc .= '</ol>' x ($last_level - $level);
}
