# Java线程池执行任务的两种机制，invokeAll和 CompletionService

通常Java线程池执行的任务有两种类型，一种是不带返回值的Runnable， 另一种是带返回值的Callable。<br />?<br />对于不带返回值的任务通常我们不太关注任务是否执行结束以及结束后应该做做些什么，我们将任务提交给线程池， 然后顾自己干别的事情。<br />?<br />带返回值的任务执行结果通常受到当前任务的依赖，任务提交给线程池后还需要等待任务的返回。对于任务结果我们会有不同的需求，有时候当前任务依赖所有提交给线程池的任务的结果， 而有时候有只依赖某一个任务的执行结果，就好比饭店的服务员需要等待宝箱中所有顾客用餐完毕才来收拾，而食堂的阿姨却可以单个学生用餐完毕而来收拾。<br />?<br />Java线程池对对于这两种需求提供不同的解决方案<br />?<br />对于依赖所有任务执行结果的可以直接使用线程池的invokeAll方法

```java
public class Main {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        List<Callable<Integer>> tasks = new ArrayList<>();
        for( int i = 0; i < 10; i++) {
            tasks.add(()->{
                Random random = new Random();
                int second = random.nextInt(10);
                Thread.sleep(second * 1000) ;
                return second;
            });
        }
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        List<Future<Integer>> futures = executorService.invokeAll(tasks);
        for( int i = 0; i < futures.size(); i++) {
            System.out.println(futures.get(i).get());
        }

        executorService.shutdown();
    }
}
```

以上程序清单中的线程池执行10个任务，这些任务会做随机延时，所有的任务都放在tasks变量中。<br />?<br />我们初始化一个长度为时的固定大小的线程池执行这些任务，方法invokeAll调用会阻塞，在所有任务执行完毕后返回，然后程序打印这些返回结果。我们运行这段代码会卡断很长时间，接着瞬间出结果， 这是invokeAll的特性：所欲任务必须执行完毕后才返回。<br />?<br />对于不依赖所有任务的执行结果，而可以单独处理每个任务结果的，invokeAll就显得不友好了，虽然最终结果没区别，执行完所有任务都需要话同样的时间，可是执行完一个任务就处理一个任务的结果不是显得更加人性化么，比如加载多张网络图片，加载完成一张就显示一张显然有更好的用户体验，对于这种需求我们可以使用CompletionService。<br />?<br />CompletionService能逐个返回任务的执行结果，谁先执行完毕返回谁。 它利用了阻塞队列的特想，当它察觉到有任务执行完毕时则将执行的结果，一个Future放入它维护的一个无界阻塞队列，外部程序就可以通过take方法拿取，如果阻塞队列为空，也就是还没有执行完毕的任务， 那么take方法则阻塞，外部程序继续等待。

```java
public class Main {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        List<Callable<Integer>> tasks = new ArrayList<>();
        for( int i = 0; i < 10; i++) {
            tasks.add(()->{
                Random random = new Random();
                int second = random.nextInt(10);
                Thread.sleep(second * 1000) ;
                return second;
            });
        }
        ExecutorService executorService = Executors.newFixedThreadPool(10);

        CompletionService<Integer> completionService = new ExecutorCompletionService(executorService);
        tasks.forEach(task -> completionService.submit(task));

        for( int i = 0; i < tasks.size(); i++) {
            System.out.println(completionService.take().get());
        }

        executorService.shutdown();
    }
}
```

执行上面的代码不会长时间卡断后瞬间出结果，它会平缓的打印每个任务的执行结果， 知道所有任务执行完毕而结束程序。 
