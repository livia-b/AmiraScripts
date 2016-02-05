"""
Conversion to Amira Landmarks.landmarkAscii format (from slicer fiducial list)
"""
import pandas as pd

amiraTemplate = """
# Avizo 3D ASCII 2.0


define Markers %s

Parameters {
    NumSets 1,
    ContentType "LandmarkSet"
}

Markers { float[3] Coordinates } @1

# Data section follows
@1
"""


def convertSlicerFiducialListToAmiralandmarkAscii(inFilename, outFilename):
    if not inFilename.endswith('.fcsv'):
        print "The file seems not to be of the correct format"
    if not outFilename.endswith('.landmarkAscii'):
        outFilename += '.landmarkAscii'
    landmarksRAS = pd.read_csv(inFilename, skiprows=2); 
    print landmarksRAS
    landmarks = pd.DataFrame()
    landmarks['z'] = landmarksRAS['z']
    for j in ['x','y']:
        landmarks.loc[:,j] = -landmarksRAS.loc[:,j]
    nMarkers=landmarks.shape[0]
    #check RAS orientation?
    txt = amiraTemplate % nMarkers
    for i in range(nMarkers):
        txt += " ".join(["%.12e" %(landmarks.loc[i,j]) for j in ['x','y','z']])
        txt += "\n"
    with open(outFilename, 'wb') as f:
        f.write(txt)
        

if __name__ == '__main__':
    import sys
    convertSlicerFiducialListToAmiralandmarkAscii(sys.argv[1], sys.argv[2])
        
    
    
