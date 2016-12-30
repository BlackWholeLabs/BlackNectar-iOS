/**
 * Autogenerated by Thrift Compiler (0.9.3)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"
#import "TObjective-C.h"
#import "TBase.h"
#import "TAsyncTransport.h"
#import "TProtocolFactory.h"
#import "TBaseClient.h"

#import "Authentication.h"
#import "Aroma.h"
#import "Channels.h"
#import "Endpoint.h"
#import "Events.h"
#import "Exceptions.h"
#import "ApplicationService.h"
#import "AromaService.h"

typedef Aroma_int MessageService_int;

typedef Aroma_long MessageService_long;

typedef Aroma_timestamp MessageService_timestamp;

typedef AromaAuthentication_ApplicationToken * MessageService_ApplicationToken;

typedef AromaAuthentication_AuthenticationToken * MessageService_AuthenticationToken;

typedef AromaAuthentication_UserToken * MessageService_UserToken;

typedef Aroma_Application * MessageService_Application;

typedef int MessageService_Urgency;

typedef AromaEvents_Event * MessageService_Event;

typedef AromaException_AccountAlreadyExistsException * MessageService_AccountAlreadyExistsException;

typedef AromaException_InvalidArgumentException * MessageService_InvalidArgumentException;

typedef AromaException_InvalidCredentialsException * MessageService_InvalidCredentialsException;

typedef AromaException_InvalidTokenException * MessageService_InvalidTokenException;

typedef AromaException_OperationFailedException * MessageService_OperationFailedException;

typedef AromaException_ApplicationAlreadyRegisteredException * MessageService_ApplicationAlreadyRegisteredException;

typedef AromaException_ApplicationDoesNotExistException * MessageService_ApplicationDoesNotExistException;

typedef AromaException_CustomChannelUnreachableException * MessageService_CustomChannelUnreachableException;

typedef AromaException_ChannelDoesNotExistException * MessageService_ChannelDoesNotExistException;

typedef AromaException_UnauthorizedException * MessageService_UnauthorizedException;

typedef ApplicationService_SendMessageRequest * MessageService_SendMessageRequest;

typedef ApplicationService_SendMessageResponse * MessageService_SendMessageResponse;

typedef AromaService_DeleteMessageRequest * MessageService_DeleteMessageRequest;

typedef AromaService_DeleteMessageResponse * MessageService_DeleteMessageResponse;

typedef AromaService_DismissMessageRequest * MessageService_DismissMessageRequest;

typedef AromaService_DismissMessageResponse * MessageService_DismissMessageResponse;

typedef AromaService_GetApplicationMessagesRequest * MessageService_GetApplicationMessagesRequest;

typedef AromaService_GetApplicationMessagesResponse * MessageService_GetApplicationMessagesResponse;

typedef AromaService_GetInboxRequest * MessageService_GetInboxRequest;

typedef AromaService_GetInboxResponse * MessageService_GetInboxResponse;

typedef AromaService_GetFullMessageRequest * MessageService_GetFullMessageRequest;

typedef AromaService_GetFullMessageResponse * MessageService_GetFullMessageResponse;

@protocol MessageService_MessageService <NSObject>
- (double) getApiVersion;  // throws TException
@end

@interface MessageService_MessageServiceClient : TBaseClient <MessageService_MessageService> - (id) initWithProtocol: (id <TProtocol>) protocol;
- (id) initWithInProtocol: (id <TProtocol>) inProtocol outProtocol: (id <TProtocol>) outProtocol;
@end

@interface MessageService_MessageServiceProcessor : NSObject <TProcessor> {
  id <MessageService_MessageService> mService;
  NSDictionary * mMethodMap;
}
- (id) initWithMessageService: (id <MessageService_MessageService>) service;
- (id<MessageService_MessageService>) service;
@end

@interface MessageService_MessageServiceConstants : NSObject {
}
+ (MessageService_int) SERVICE_PORT;
+ (AromaEndpoint_TcpEndpoint *) PRODUCTION_ENDPOINT;
+ (AromaEndpoint_TcpEndpoint *) BETA_ENDPOINT;
+ (Aroma_LengthOfTime *) DEFAULT_MESSAGE_LIFETIME;
@end
