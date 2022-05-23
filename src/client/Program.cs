using System;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;


//Fix me
//Example: https://github.com/briandenicola/todo-app-azure-sql/blob/acdac15dc6fb441c2b019141467b657f40a78a11/src/Program.cs
const string connectionString = "";
const string eventHubName = "requests";
 
EventHubProducerClient producerClient = new EventHubProducerClient(connectionString, eventHubName);

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
