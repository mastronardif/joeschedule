SCH_xmLRD()
{
   my($leftVal, $rightVal,  @lines) = @_;
   my @results;

   $leftVal =~ /<(.*?)>/i;
   my $tag = $1 || "";


#print("FUCKYOU tag($tag)\n");
   $leftVal =~ /<\s*\b$tag\b\s*>(.*)<\s*\/\b$tag\b\s*>/igs;
   $leftVal = $1 || "";
#print("FUCKYOU leftval($leftVal)\n");

   my @xmlkeys = split /,\s*/, $rightVal;  

   # key, value pairs.
   my %kd = ();

   for my $x(0 .. $#xmlkeys) {

      $xmlkeys[$x] =~ /<\s*(.*)\s*>/igs;

      my $trim = $1;
      $trim =~ s/^\s+//;
      $trim =~ s/\s+$//;

      $xmlkeys[$x] = $1;

      $kd{$trim} = "$x";
   }

   my $parent = $xmlkeys[0];


   my $section = "";
   my $left    = 0;
   my $right   = 0;

   my @xmlValues = @xmlkeys;
   for my $x(0 .. $#lines) {

      # get begin parent.
      if ($lines[$x] =~ /<\s*\b$parent\b\s*>/i)
      {
         $left = 1;
      }

      # get end parent.
      if ($lines[$x] =~ /<\/\s*\b$parent\b\s*>/i)
      {
         $right = 1;
      }

      if ($left && !$right)
      {
          # copy section.
          $section = "$section$lines[$x]";
      }
      

      if ($left && $right)
      {
         # copy section.
         $section = "$section$lines[$x]";

         #$section =~ /<\s*\b$parent\b\s*>(.*)<\s*\/\b$parent\b\s*>/igs;
         $section =~ /<\s*\b$parent\b\s*>(.*)<\s*\/\b$parent\b\s*>/is;

         my $tag;
         #get section values.
         # FM 9/30/03 for $zz(1 .. $#xmlkeys) {
         for my $zz(0 .. $#xmlkeys) 
         {
            $xmlValues[$zz] = "";

            $tag = $xmlkeys[$zz];

            $kd{$xmlkeys[$zz]} = "";

#            $section =~ /<\s*\b$tag\b\s*>(.*)<\s*\/\b$tag\b\s*>/igs;
            $section =~ /<\s*\b$tag\b\s*>(.*?)<\s*\/\b$tag\b\s*>/is;

            my $trim= $1 || "";
            if ($1)
            {
               $trim = "$1";

            # FM 1/26/04 replace " and '
            $trim =~ tr/"/'/;
            $trim =~ s/'/&\#39;/g;
            # FM 1/26/04

               $trim =~ s/^\s+//;
               $trim =~ s/\s+$//;
            }

            $xmlValues[$zz] = $trim;
            $kd{$xmlkeys[$zz]} = $trim;
         }

         #FM 9/21/03
         my $update;

         #cheese for now.
         if ($xmlkeys[0]=~ /Picture/i)
         {
            $kd{NAME} = "$picroot$kd{NAME}";
         }

         $update = $leftVal;
#print("\nFUCK2u1($update)\n");


         # FM 9/30/03 for $zz(1 .. $#xmlkeys) {
         for my $zz(0 .. $#xmlkeys) {
            $update =~ s/<\s*$xmlkeys[$zz]\s*>/$kd{$xmlkeys[$zz]}/igs;
#print("\nFUCK $xmlkeys[$zz] === $kd{$xmlkeys[$zz]}\n");
         }

#print("\nFUCK2u2($update)\n");
         #print $update;
         #$results = "$results$update";
         push(@results, $update);
     
         $left    = 0;
         $right   = 0;
         $section = "";
      }
   }

   return @results;
}