//
//  main.m
//  TestNet
//
//  Created by Eugenijus Margalikas     on 20/04/2017.
//  Copyright © 2017 Eugenijus Margalikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

static int i = 3;

static void handleConnect(CFSocketRef s,
                   CFSocketCallBackType callbackType,
                   CFDataRef address,
                   const void *data,
                          void *info){
   
    
    NSLog(@"someone trying to connect %i", i);i--;
    if (i<=0) CFRunLoopStop(CFRunLoopGetCurrent());
    //int fd = * (const int *) data;

};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // insert code here...
        
        CFSocketRef myIpV4CFSock = CFSocketCreate(
                                                  kCFAllocatorDefault,
                                                  PF_INET,
                                                  SOCK_STREAM,
                                                  IPPROTO_TCP,
                                                  kCFSocketAcceptCallBack,
                                                  handleConnect,
                                                  NULL);
        
        struct sockaddr_in sin;
        
        memset(&sin, 0, sizeof(sin));
        
        sin.sin_len         = sizeof(sin);
        sin.sin_family      = AF_INET;
        sin.sin_port        = htons(49620);
        sin.sin_addr.s_addr = htonl(INADDR_ANY);
        
        CFDataRef sincfd= CFDataCreate(
                                 kCFAllocatorDefault,
                                 (UInt8*) &sin,
                                 sizeof(sin));
        
        if(kCFSocketSuccess != CFSocketSetAddress(myIpV4CFSock, sincfd)) return -1;
        
        CFRelease(sincfd);
        
        CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(
                                                                      kCFAllocatorDefault,
                                                                      myIpV4CFSock,
                                                                      0);
        
        CFRunLoopAddSource(
                           CFRunLoopGetCurrent(),
                           socketsource,
                           kCFRunLoopDefaultMode);
        CFRelease(socketsource);
        
        NSLog(@"Hello, World!");

        NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(myIpV4CFSock);
        
        const struct sockaddr_in * sc = [addr bytes];
        
        unsigned int port = ntohs((sc)->sin_port);
        
        NSLog(@"addr %i.%i.%i.%i:%i", (sc->sin_addr.s_addr & 0xFF000000) >> 24,
                                      (sc->sin_addr.s_addr & 0x00FF0000) >> 16,
                                      (sc->sin_addr.s_addr & 0x0000FF00) >> 8,
                                      (sc->sin_addr.s_addr & 0x000000FF),
                                       port);
        
        CFRunLoopRun();
        
        
        
    }
    return 0;
}

