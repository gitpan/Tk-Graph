use ExtUtils::MakeMaker;

WriteMakefile (
	'NAME'		=> 'Tk::Graph',
	'DISTNAME'	=> 'Tk-Graph',
	'VERSION'	=> '0.03',
	'AUTHOR'	=> 'Frank Herrmann <xpix@netzwert.ag>',
	'ABSTRACT'	=> 'Tk::Graph - Realtime Chartmaker Widget',
	
	'dist'		=> { 'COMPRESS' => 'gzip -9f', 'SUFFIX' => 'gz' },
);

