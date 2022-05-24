const string eventHubName = "requests";

var namespaceOption = new Option<string>(
        new [] {"--event-hub-namespace", "-n"},
        description: "The Event Hub Namespace name to push sample events to");


var rootCommand = new RootCommand
{
    namespaceOption
};


rootCommand.Description = "A client app to publish sample events to Azure Event Hub";
rootCommand.SetHandler( async (string eventhubNameSpace) =>
{  
    var credential = new ChainedTokenCredential(new AzureCliCredential());
    var eventHubNameSpaceFQDN = $"{eventhubNameSpace}.servicebus.windows.net";
    var producerClient = new EventHubProducerClient(eventHubNameSpaceFQDN, eventHubName, credential);
    
    using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();

    for (int i = 1; i <= 5; i++)
    {
        if (! eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes($"Event {i}"))))
        {
            throw new Exception($"Event {i} is too large for the batch and cannot be sent.");
        }
    }

    try {
        await producerClient.SendAsync(eventBatch);
        Console.WriteLine($"A batch of 5 events has been published.");
    }
    finally {
        await producerClient.DisposeAsync();
    }
}, namespaceOption);

return rootCommand.InvokeAsync(args).Result;


