#!/bin/perl
# 
# Coded by Constantine in 19/03/2015.
# Site: constantine.sourceforge.net
# 
# Modules...
#   cpan Socket
# 

use Socket;

sub main 
{
  if (@ARGV == 2)
  {
    my $list_of_dorks = @ARGV [0];
    my $number_of_pages = @ARGV [1];
    
    show_banner ();
    print "\nSatanDork started...\n\n";
    create_files();
    
    open (my $handle, "<", $list_of_dorks) or die "Cannot open < ". $list_of_dorks .": $!";
    while (<$handle>) 
    {
      my $dork = trim($_);
      if (length($dork)) 
      {
        $dork =~ tr/ /+/;
        for (my $page = 0; $page < $number_of_pages; $page++)
        {
          print "Dorking: ". $dork ." - Page: ". $page . "\n";
          
          my $response = send_http_request ("/search?q=". $dork ."&first=". $page ."1&FORM=PERE");
          while( $response =~ m/<a href="http(.+?)"/gi ) 
          {
            my $link = $1;
            unless ( index($link, "msn.com") > 0 || index($link, "microsofttranslator.com") > 0 ||
                     index($link, "microsoft.com") > 0 || index($link, "facebook.com") > 0 || index($link, "twitter.com") > 0 )
            {
              $link =~ s/&amp;/&/g;
              my @array_a = split /:\/\//, $link;
              my @array_b = split /\//, $array_a[1];
              $link = $array_b[0];
              
              save_link_to_file ($link);
            }
          }
        }
      }
    }
    
    print "\n \e[0m \n";
    close($handle);
  }
  else 
  {
    show_banner ();
    print "\n   Use: perl $0 list_of_dorks.txt number_of_pages\n";
    print "   Example: perl $0 list_of_dorks.txt 40\e[0m \n\n";
  }
}

sub send_http_request 
{
  my $host = "bing.com";
  my $port = 80;
  my $response = "";
  
  socket ( SOCKET, PF_INET, SOCK_STREAM, (getprotobyname('tcp'))[2] ) or die "Can't create a socket!\n";
  connect ( SOCKET, pack_sockaddr_in($port, inet_aton($host)) ) or die "Can't connect to port: ". $port ."!\n";
  
  my @header = 
  (
    "GET ". @_[0] ." HTTP/1.1\r\n",
    "Host: www.bing.com\r\n",
    "User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:33.0) Gecko/20100101 Firefox/33.0\r\n",
    "Connection: Close\r\n\r\n"
  );
  
  foreach my $index (@header) 
  {
    send ( SOCKET, $index, 0 );
  }
  
  while (<SOCKET>) 
  {
    $response .= "$_";
  }
  
  close ( SOCKET );
  return $response;
}

sub save_link_to_file
{
  my ($link) = @_;
  
  # Save to all.
  open (my $handle_a, "+>>", "output_all.txt");
  print {$handle_a} $link . "\n";
  close ($handle_a);
  
  # Save unique URL.
  my $status = 0;
  
  open (my $handle_b, "<", "output_domains.txt") or die "Cannot open < output_domains.txt: $!";
  while (<$handle_b>)
  {
    my $domain = trim($_);
    if (length($domain))
    {
      if ($domain =~ $link)
      {
        $status = 1;
      }
    }
  }
  close ($handle_b);
  
  if ($status == 0)
  {
    open (my $handle_c, "+>>", "output_domains.txt");
    print {$handle_c} $link . "\n";
    close ($handle_c);
  }
}

sub create_files
{
  open (my $handle_a, ">", "output_domains.txt");
  close ($handle_a);
  
  open (my $handle_b, ">", "output_all.txt");
  close ($handle_b);
}

sub show_banner 
{
  print "\n\n\e[31m                         (                      )\n";
  print "                         |\\    _,--------._    / |\n";
  print "                         | `.,'            `. /  |\n";
  print "                         `  '              ,-'   '\n";
  print "                          \\/_         _   (     /\n";
  print "                         (,-.`.    ,',-.`. `__,'\n";
  print "                          |/\e[33m#\e[31m\\ ),-','\e[33m#\e[31m\\`= ,'.` |\n";
  print "                          `._/)  -'.\\_,'   ) ))|\n";
  print "                          /  (_.)\\     .   -'//\n";
  print "                         (  /\\____/\\    ) )`'\\\n";
  print "                          \\ |\e[37mV\e[31m----\e[37mV\e[31m||  ' ,    \n";
  print "                           |`- -- -'   ,'   \\  \\      _____\n";
  print "                    ___    |         .'    \\ \\  `._,-'     `-\n";
  print "                       `.__,`---^---'       \\ ` -'\n";
  print "                          -.______  \\ . /  ______,-\n";
  print "                                  `.     ,'            ap\n\n";
  print "                      \e[33mSatanDorker - Coded by Constantine.\n";
  print "                         \e[1;34mconstantine.sourceforge.net \e[32m \n\n";
  print "                        Greatz for P0cl4bs and my friends... \n";
  print "                            https://github.com/P0cL4bs\n\n";
  print "    L1sbeth, foreach, 0x29a, xstpl, sup3rman, j0shua3w, Mmxm, Anonymous_, lpax\n";
  print "     c00ler, m0nad, sigsegv, enygmata, eremitah, Otacon, KvN, Al3xG0, Erick \n";
  print " H3LLS1ng, Eletronico, l4rg4d0, mvrech, DarkCrypter, nbdu1nder, Orc, Snow, Nosomy\n";
  print "    Arion, LiFux, Zeus, Chainksain, shadow, _mlk_, sexpistol, Haxixe, shadow \n";
  print "  0fx66,Tr3v0r, ph4ck3r, bl4de, DarkCrypter, Depois, K4r4t3k1d... and all friends.\n";
  print "\n";
}

sub trim 
{
  my $s = shift;
  $s =~ s/^\s+|\s+$//g;
  return $s
};

main;

# EOF.
