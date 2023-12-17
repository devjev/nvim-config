"""
Fallback launch for some legacy machines
"""
from jedi_language_server.server import SERVER

if __name__ == '__main__':
    SERVER.start_io()

