@rem Make APNG/webp
@rem Use ffmpeg.exe
@rem 
@rem ffmpeg -i frames/%%08d.png -r 24 -plays 0 out.apng -y
ffmpeg -i frames/%%08d.png -r 24 -plays 0 out.webp -y
