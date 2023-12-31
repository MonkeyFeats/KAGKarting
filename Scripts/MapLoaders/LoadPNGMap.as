#include "KarPNGLoader.as";
#include "LoadMapUtils.as";
#include "MinimapHook.as";

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING PNG MAP " + fileName);

	PNGLoader loader();

	return loader.loadMap(map, fileName);
}

class PNGLoader
{
	PNGLoader()	{}

	CFileImage@ image;
	CMap@ map;

	bool loadMap( CMap@ _map, const string& in filename)
	{
		@map = _map;

		if (!getNet().isServer())
		{
			CMap::SetupMap( map, 0, 0 );
			return true;
		}

		@image = CFileImage( filename );		
		if (image.isLoaded())
		{
			CMap::SetupMap( map, image.getWidth(), image.getHeight() );

			while (image.nextPixel())
			{
				SColor pixel = image.readPixel();
				int offset = image.getPixelOffset();
				Vec2f pixelPos = image.getPixelPosition();
				CMap::handlePixel( map, image, pixel, offset, pixelPos );
				getNet().server_KeepConnectionsAlive();
			}
			MiniMap::Initialise();
			return true;
		}
		return false;
	}
 
}
