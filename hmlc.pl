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
$document =~ s#·(.*)#<kbd>$1</kbd>#g;
$document =~ s#\n((?:·.*\n)+)#\n<ul>\n$1</ul>\n#gm;
$document =~ s#^·\s*#<li>#gm;
make_headlines();

my %colortheme_dark = (
    body_background => '#14171f',
    body_color => '#a0a0a0',
    a_link_color => '#667fb8',
    a_visited_color => '#8873b0',
    code_background => '#1a1f29',
    BORDER => '#2a334a',
    pre_background => '#1a1f29',
    kbd_color => '#ca2e15',
    dfn_color => '#80a0ff',
);

%colortheme_dark = (
    body_background => '#151820',
    body_color => '#a0a0a0',
    a_link_color => '#5873b0',
    a_visited_color => '#8873b0',
    code_background => '#0e1826',
    BORDER => '#394052',
    pre_background => '#0e1826',
    kbd_color => '#ca2e15',
    dfn_color => '#5873b0',
);

my %colortheme_light = (
    body_background => '#EFEDE2',
    body_color => '#000000',
    a_link_color => '#0000ff',
    a_visited_color => '#b10040',
    code_background => '#E6DFCE',
    BORDER => '#aaaaaa',
    pre_background => '#E6DFCE',
    kbd_color => '#a00000',
    dfn_color => '#0000aa',
);

print <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <style type="text/css">
  @{[make_css(%colortheme_dark)]}
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

    while ($document =~ /^(−+) (.+)/gm) {
        my $headline = $2;
        $level = length $1;
        if ($level > $last_level) {
            $index_counter[$level] = 1;
        } else {
            $index_counter[$level]++;
        }

        my $index = make_index($level, \@index_counter);
        $document =~ s#^−(.*)#<h$level><a class=nolink name="$index">$index $headline</a></h$level>#m;

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

sub make_css {
    my %colors = @_;

    return <<EOF;
    body {
        background: $colors{body_background};
        color: $colors{body_color};
        font-family: sans-serif;
    }

    a:link {
        color: $colors{a_link_color};
        text-decoration: none;
    }

    a:visited {
        color: $colors{a_visited_color};
        text-decoration: none;
    }

    a:active, a:hover {
        text-decoration: underline;
    }

    a.nolink {
        text-decoration: none;
    }

    code {
        font-size: 11pt;
        font-weight: normal;
        border: 1px solid $colors{BORDER};
        border-radius: 3px 3px;
        padding: 1px 1px 1px 1px;
        background: $colors{code_background};
        margin: 0 0 0 0;
    }

    pre {
        font-size: 11pt;
        font-weight: normal;
        border: 1px solid $colors{BORDER};
        border-radius: 3px 3px;
        padding: 3px 3px 3px 3px;
        background: $colors{pre_background};
        margin: 0 0 0 0;
    }

    table {
        margin: 1ex 0 1ex 0;
    }

    kbd {
        font-style: normal;
        font-weight: bold;
        color: $colors{kbd_color};
    }

    dfn {
        font-weight: bold;
        color: $colors{dfn_color};
    }
EOF
}
